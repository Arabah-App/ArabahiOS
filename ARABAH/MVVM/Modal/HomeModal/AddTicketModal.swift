//
//  AddTicketModal.swift
//  ARABAH
//
//  Created by cqlios on 12/12/24.
//

import Foundation

// MARK: - AddTicketModal
struct AddTicketModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: AddTicketModalBody?
}

// MARK: - AddTicketModalBody
struct AddTicketModalBody: Codable {
    let userID, title, description: String?
    let deleted: Bool?
    let id, createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case title = "Title"
        case description = "Description"
        case deleted
        case id = "_id"
        case createdAt, updatedAt
        case v = "__v"
    }
}
