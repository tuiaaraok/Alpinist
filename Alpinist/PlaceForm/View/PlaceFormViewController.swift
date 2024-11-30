//
//  PlaceFormViewController.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import UIKit
import Combine
import FSPagerView
import PhotosUI

class PlaceFormViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: BaseButton!
    @IBOutlet weak var nameTextField: BaseTextField!
    @IBOutlet weak var startDateTextField: BaseTextField!
    @IBOutlet weak var endDateTextField: BaseTextField!
    @IBOutlet weak var heightTextField: BaseTextField!
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var pageControl: FSPageControl!
    @IBOutlet weak var pagerViewHeightConst: NSLayoutConstraint!
    private let viewModel = PlaceFormViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    var completion: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle(title: "Add hike")
        self.navigationItem.hidesBackButton = true
        membersTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        setupUI()
        subscribe()
        registerKeyboardNotifications()
    }
    
    func setupUI() {
        titleLabels.forEach({ $0.font = .regular(size: 20) })
        addPhotoButton.titleLabel?.font = .regular(size: 20)
        cancelButton.titleLabel?.font = .regular(size: 20)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addShadow()
        startDateTextField.setupRightViewIcon(.calendar, size: CGSize(width: 40, height: 40))
        endDateTextField.setupRightViewIcon(.calendar, size: CGSize(width: 40, height: 40))
        membersTableView.register(UINib(nibName: "MemberTableViewCell", bundle: nil), forCellReuseIdentifier: "MemberTableViewCell")
        membersTableView.delegate = self
        membersTableView.dataSource = self
        nameTextField.delegate = self
        heightTextField.delegate = self
        startDatePicker.locale = NSLocale.current
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .inline
        startDatePicker.addTarget(self, action: #selector(startDatePickerValueChanged), for: .valueChanged)
        startDateTextField.inputView = startDatePicker
        endDatePicker.locale = NSLocale.current
        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .inline
        endDatePicker.addTarget(self, action: #selector(endDatePickerValueChanged), for: .valueChanged)
        endDateTextField.inputView = endDatePicker
        pagerView.layer.masksToBounds = true
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.contentMode = .center
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.itemSize = pagerView.bounds.size
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.itemSize = pagerView.bounds.size
        pagerView.layer.borderColor = UIColor.baseGray.cgColor
        pagerView.layer.borderWidth = 2
        pageControl.contentHorizontalAlignment = .center
        pageControl.setFillColor(.white, for: .selected)
        pageControl.setFillColor(.black, for: .normal)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newSize = change?[.newKey] as? CGSize {
                updateTableViewHeight(newSize: newSize)
            }
        }
    }

    private func updateTableViewHeight(newSize: CGSize) {
        tableViewHeightConst.constant = newSize.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func subscribe() {
        viewModel.$place
            .receive(on: DispatchQueue.main)
            .sink { [weak self] place in
                guard let self = self else { return }
                self.pagerViewHeightConst.constant = (place.photo.isEmpty && place.video.isEmpty) ? 0 : 200
                self.saveButton.isEnabled = (place.name.checkValidation() && place.startDate != nil && place.endDate != nil && place.height != nil)
                self.nameTextField.text = place.name
                self.startDateTextField.text = place.startDate?.toString()
                self.endDateTextField.text = place.endDate?.toString()
                self.pageControl.numberOfPages = (place.photo.count + place.video.count)
                if let height = place.height {
                    self.heightTextField.text = "\(height)"
                }
                if place.members.count != self.viewModel.previousMembersCount {
                    self.membersTableView.reloadData()
                    self.viewModel.previousMembersCount = place.members.count
                } else {
                    self.pagerView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func startDatePickerValueChanged() {
        endDatePicker.minimumDate = startDatePicker.date
        viewModel.place.startDate = startDatePicker.date
    }
    
    @objc func endDatePickerValueChanged() {
        startDatePicker.maximumDate = endDatePicker.date
        viewModel.place.endDate = endDatePicker.date
    }
    
    func choosePhoto() {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.requestCameraAccess()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.requestPhotoLibraryAccess()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view // Your source view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func handleTapGesture(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func clickedAddMember(_ sender: UIButton) {
        viewModel.addMember()
    }
    
    @IBAction func clickedSave(_ sender: BaseButton) {
        viewModel.save { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                self.completion?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func clickedAddPhoto(_ sender: UIButton) {
        choosePhoto()
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        viewModel.clear()
    }
    
    private func writeVideoToTempFile(videoData: Data) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".mp4"
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        do {
            try videoData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error writing video data to temporary file: \(error)")
            return nil
        }
    }
}

extension PlaceFormViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            viewModel.place.name = textField.text
        case heightTextField:
            viewModel.place.height = Int(textField.text ?? "")
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == heightTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

extension PlaceFormViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.place.members.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
        cell.configure(name: viewModel.place.members[indexPath.section])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
}

extension PlaceFormViewController: MemberTableViewCellDelegate {
    func changeName(cell: UITableViewCell, value: String?) {
        if let indexPath = membersTableView.indexPath(for: cell) {
            viewModel.place.members[indexPath.section] = value ?? ""
        }
    }
}

extension PlaceFormViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(PlaceFormViewController.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                scrollView.contentInset = .zero
            } else {
                let height: CGFloat = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)!.size.height
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}

extension PlaceFormViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return (viewModel.place.photo.count + viewModel.place.video.count)
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if index < viewModel.place.photo.count {
            cell.imageView?.isHidden = false
            let data = viewModel.place.photo[index]
            cell.imageView?.contentMode = .scaleAspectFill
            cell.imageView?.image = UIImage(data: data)
            removeVideoLayer(from: cell)
        } else {
            cell.imageView?.isHidden = true
            let data = viewModel.place.video[index - viewModel.place.photo.count]
            if let videoURL = writeVideoToTempFile(videoData: data) {
                playVideo(in: cell, from: videoURL)
            }
        }
        
        return cell
    }
        
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
//        choosePhoto()
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
    
    private func playVideo(in cell: FSPagerViewCell, from url: URL) {
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = cell.bounds
        playerLayer.videoGravity = .resizeAspectFill
        cell.layer.addSublayer(playerLayer)
        player.play()
    }
    
    private func removeVideoLayer(from cell: FSPagerViewCell) {
        if let sublayers = cell.layer.sublayers {
            for layer in sublayers where layer is AVPlayerLayer {
                layer.removeFromSuperlayer()
            }
        }
    }
}

extension PlaceFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func requestCameraAccess() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.openCamera()
                }
            }
        case .authorized:
            openCamera()
        case .denied, .restricted:
            showSettingsAlert()
        @unknown default:
            break
        }
    }
    
    private func requestPhotoLibraryAccess() {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        switch photoStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                if status == .authorized {
                    self.openPhotoLibrary()
                }
            }
        case .authorized:
            openPhotoLibrary()
        case .denied, .restricted:
            showSettingsAlert()
        case .limited:
            break
        @unknown default:
            break
        }
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(title: "Access Needed", message: "Please allow access in Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func openCamera() {
            DispatchQueue.main.async {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.mediaTypes = ["public.image", "public.movie"]
                    imagePicker.videoQuality = .typeHigh
                    imagePicker.allowsEditing = true
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        }
        
        private func openPhotoLibrary() {
            DispatchQueue.main.async {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.mediaTypes = ["public.image", "public.movie"]
                    imagePicker.allowsEditing = true
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let mediaType = info[.mediaType] as? String {
                switch mediaType {
                case "public.image":
                    handlePickedImage(info)
                case "public.movie":
                    handlePickedVideo(info)
                default:
                    break
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        private func handlePickedImage(_ info: [UIImagePickerController.InfoKey: Any]) {
            var image: UIImage?
            if let editedImage = info[.editedImage] as? UIImage {
                image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                image = originalImage
            }
            if let imageData = image?.jpegData(compressionQuality: 1.0) {
                viewModel.addPhoto(data: imageData)
            }
        }
        
        private func handlePickedVideo(_ info: [UIImagePickerController.InfoKey: Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                do {
                    let videoData = try Data(contentsOf: videoURL)
                    viewModel.addVideo(data: videoData)
                } catch {
                    print("Failed to read video data: \(error)")
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
}
