//
//  PlacesViewModel.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import Foundation

class PlacesViewModel {
    static let shared = PlacesViewModel()
    private var data: [PlaceModel] = []
    @Published var places: [PlaceModel] = []
    var selectedType = 0
    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchPlaces { [weak self] places, _ in
            guard let self = self else { return }
            self.data = places
            filter(type: selectedType)
        }
    }
    
    func filter(type: Int) {
        selectedType = type
        places = data.filter { place in
            if let startDate = place.startDate?.stripTime() {
                if selectedType == 0 {
                    return startDate < Date().stripTime()
                } else {
                    return startDate >= Date().stripTime()
                }
            }
            return false
        }

    }
    
    func clear() {
        places = []
        selectedType = 0
    }
}
