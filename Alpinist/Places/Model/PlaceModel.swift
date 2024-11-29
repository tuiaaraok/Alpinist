//
//  PlaceModel.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import Foundation

struct PlaceModel {
    var id: UUID
    var name: String?
    var startDate: Date?
    var endDate: Date?
    var height: Int?
    var members: [String] = [""]
    var photo: [Data] = []
    var video: [Data] = []
}
