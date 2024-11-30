//
//  EquipmentFormViewModel.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 30.11.24.
//

import Foundation

class EquipmentFormViewModel {
    static let shared = EquipmentFormViewModel()
    @Published var equipments: [EquipmentModel] = [EquipmentModel(id: UUID())]
    var previousEquipmentCount: Int = 0

    private init() {}
    
    func save(completion: @escaping (Error?) -> Void) {
        equipments.removeAll(where: { !$0.name.checkValidation() })
        CoreDataManager.shared.saveEquipments(equipmentModels: equipments, completion: completion)
    }
    
    func addEquipment() {
        equipments.append(EquipmentModel(id: UUID()))
    }
    
    func clear() {
        equipments = [EquipmentModel(id: UUID())]
        previousEquipmentCount = 0
    }
}
