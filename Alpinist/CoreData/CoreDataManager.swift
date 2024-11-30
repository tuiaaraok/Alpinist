//
//  CoreDataManager.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Alpinist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func savePlace(placeModel: PlaceModel, completion: @escaping (Error?) -> Void) {
        let id = placeModel.id
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                let place: Place
                
                if let existingPlace = results.first {
                    place = existingPlace
                } else {
                    place = Place(context: backgroundContext)
                    place.id = id
                }
                
                place.name = placeModel.name
                place.startDate = placeModel.startDate
                place.endDate = placeModel.endDate
                place.height = Int64(placeModel.height ?? 0)
                place.members = placeModel.members
                place.photo = placeModel.photo
                place.video = placeModel.video
                
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchPlaces(completion: @escaping ([PlaceModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                var placesModel: [PlaceModel] = []
                for result in results {
                    let placeModel = PlaceModel(id: result.id ?? UUID(), name: result.name, startDate: result.startDate, endDate: result.endDate, height: Int(result.height), members: result.members ?? [], photo: result.photo ?? [], video: result.video ?? [])
                    placesModel.append(placeModel)
                }
                DispatchQueue.main.async {
                    completion(placesModel, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
    func saveEquipments(equipmentModels: [EquipmentModel], completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            do {
                for equipmentModel in equipmentModels {
                    let fetchRequest: NSFetchRequest<Equipment> = Equipment.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", equipmentModel.id as CVarArg)
                    
                    let results = try backgroundContext.fetch(fetchRequest)
                    let equipment: Equipment
                    
                    if let existingEquipment = results.first {
                        equipment = existingEquipment
                    } else {
                        equipment = Equipment(context: backgroundContext)
                        equipment.id = equipmentModel.id
                    }
                    
                    equipment.name = equipmentModel.name
                    equipment.isConfirmed = equipmentModel.isConfirmed
                }
                
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

    
    func fetchEquipments(completion: @escaping ([EquipmentModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Equipment> = Equipment.fetchRequest()
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                var equipmentsModel: [EquipmentModel] = []
                for result in results {
                    let equipmentModel = EquipmentModel(id: result.id ?? UUID(), name: result.name, isConfirmed: result.isConfirmed)
                    equipmentsModel.append(equipmentModel)
                }
                DispatchQueue.main.async {
                    completion(equipmentsModel, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
    func confirmEquipment(id: UUID, completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Equipment> = Equipment.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                if let equipemnt = results.first {
                    equipemnt.isConfirmed.toggle()
                } else {
                    completion(NSError(domain: "CoreDataManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Order not found"]))
                }
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

}
