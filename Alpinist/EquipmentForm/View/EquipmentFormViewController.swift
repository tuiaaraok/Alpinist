//
//  EquipmentFormViewController.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 30.11.24.
//

import UIKit
import Combine

class EquipmentFormViewController: UIViewController {

    @IBOutlet weak var equipmentsTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: BaseButton!
    @IBOutlet weak var titleLabel: UILabel!
    private let viewModel = EquipmentFormViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    var completion: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        registerKeyboardNotifications()
    }
    
    func setupUI() {
        self.navigationItem.hidesBackButton = true
        setNavigationTitle(title: "Add equipments")
        titleLabel.font = .regular(size: 20)
        cancelButton.titleLabel?.font = .regular(size: 20)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addShadow()
        equipmentsTableView.register(UINib(nibName: "MemberTableViewCell", bundle: nil), forCellReuseIdentifier: "MemberTableViewCell")
        equipmentsTableView.delegate = self
        equipmentsTableView.dataSource = self
    }
    
    func subscribe() {
        viewModel.$equipments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] equipments in
                guard let self = self else { return }
                self.saveButton.isEnabled = equipments.contains(where: { $0.name.checkValidation() })
                if equipments.count != self.viewModel.previousEquipmentCount {
                    self.equipmentsTableView.reloadData()
                    self.viewModel.previousEquipmentCount = equipments.count
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func addEquipment() {
        viewModel.addEquipment()
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func clickedCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
    
    deinit {
        viewModel.clear()
    }
}

extension EquipmentFormViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.equipments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableViewCell
        cell.configure(name: viewModel.equipments[indexPath.section].name)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section != viewModel.equipments.count - 1 { return UIView() }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let button = UIButton(type: .custom)
        button.setImage(.plus, for: .normal)
        button.addTarget(self, action: #selector(addEquipment), for: .touchUpInside)
        button.frame = CGRect(x: (footerView.frame.width - 34) / 2, y: (footerView.frame.height - 16) / 2, width: 34, height: 34)
        footerView.addSubview(button)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == viewModel.equipments.count - 1 ? 50 : 12
    }
}

extension EquipmentFormViewController: MemberTableViewCellDelegate {
    func changeName(cell: UITableViewCell, value: String?) {
        if let indexPath = equipmentsTableView.indexPath(for: cell) {
            viewModel.equipments[indexPath.section].name = value
        }
    }
}

extension EquipmentFormViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(EquipmentFormViewController.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                equipmentsTableView.contentInset = .zero
            } else {
                let height: CGFloat = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)!.size.height
                equipmentsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}
