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
