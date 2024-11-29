//
//  PlaceFormViewModel.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import Foundation

class PlaceFormViewModel {
    static let shared = PlaceFormViewModel()
    @Published var place = PlaceModel(id: UUID())
    var previousMembersCount: Int = 0
    private init() {}
    
    func addMember() {
        place.members.append("")
    }
    
    func addPhoto(data: Data) {
        place.photo.append(data)
    }
    
    func addVideo(data: Data) {
        place.video.append(data)
    }
    
    func save(completion: @escaping (Error?) -> Void) {
        place.members.removeAll(where: { !$0.checkValidation() })
        CoreDataManager.shared.savePlace(placeModel: place, completion: completion)
    }
    
    func clear() {
        place = PlaceModel(id: UUID())
        previousMembersCount = 0
    }
}
