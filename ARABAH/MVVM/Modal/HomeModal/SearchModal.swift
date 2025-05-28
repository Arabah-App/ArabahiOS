//
//  SearchModal.swift
//  ARABAH
//
//  Created by cql71 on 15/01/25.
//

import Foundation

// MARK: - SearchModal
struct SearchModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [SearchModalBody]?
}

// MARK: - SearchModalBody
struct SearchModalBody: Codable {
    let location: Location?
    let id, categoryName, image: String?
    let status: Int?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case location
        case id = "_id"
        case categoryName, image, status, deleted, createdAt, updatedAt
        case v = "__v"
    }
}
