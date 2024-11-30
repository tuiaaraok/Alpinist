//
//  EquipmentListViewController.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import UIKit
import Combine

class EquipmentListViewController: UIViewController {
    
    @IBOutlet weak var equipmentsTableView: UITableView!
    private let addEquipmentButton = UIButton(type: .custom)
    private let viewModel = EquipmentListViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupUI() {
        setNaviagtionBackButton()
        setNavigationTitle(title: "Equipment list")
        addEquipmentButton.addTarget(self, action: #selector(addEquipment), for: .touchUpInside)
        addEquipmentButton.setTitle("+Add", for: .normal)
        addEquipmentButton.setTitleColor(.black, for: .normal)
        addEquipmentButton.titleLabel?.font = .bold(size: 20)
        setNaviagtionRightButton(button: addEquipmentButton)
        equipmentsTableView.register(UINib(nibName: "EquipmentListTableViewCell", bundle: nil), forCellReuseIdentifier: "EquipmentListTableViewCell")
        equipmentsTableView.delegate = self
        equipmentsTableView.dataSource = self
    }
    
    func subscribe() {
        viewModel.$equipments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] equipments in
                guard let self = self else { return }
                if equipments.count != self.viewModel.previousEquipmentCount {
                    self.viewModel.previousEquipmentCount = equipments.count
                    self.equipmentsTableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    func openEquipmentForm() {
        let equipmentFormVC = EquipmentFormViewController(nibName: "EquipmentFormViewController", bundle: nil)
        equipmentFormVC.completion = { [weak self] in
            if let self = self {
                self.viewModel.fetchData()
            }
        }
        self.navigationController?.pushViewController(equipmentFormVC, animated: true)
    }
    
    @objc func addEquipment() {
        openEquipmentForm()
    }
    
    deinit {
        viewModel.clear()
    }
}

extension EquipmentListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.equipments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EquipmentListTableViewCell", for: indexPath) as! EquipmentListTableViewCell
        cell.configure(equipment: viewModel.equipments[indexPath.section])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        EquipmentFormViewModel.shared.equipments = [viewModel.equipments[indexPath.section]]
        openEquipmentForm()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }
}

extension EquipmentListViewController: EquipmentListTableViewCellDelegate {
    func confirmed(by id: UUID) {
        viewModel.confirmEquipment(id: id) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            }
            self.viewModel.fetchData()
        }
    }
}
