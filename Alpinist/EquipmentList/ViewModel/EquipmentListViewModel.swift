//
//  EquipmentViewModel.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import Foundation

class EquipmentListViewModel {
    static let shared = EquipmentListViewModel()
    @Published var equipments: [EquipmentModel] = []
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchEquipments { [weak self] equipments, _ in
            guard let self = self else { return }
            self.equipments = equipments
        }
    }
    
    func confirmEquipment(id: UUID, completion: @escaping (Error?) -> Void) {
        CoreDataManager.shared.confirmEquipment(id: id, completion: completion)
    }
    
    func clear() {
        equipments = []
    }
}
