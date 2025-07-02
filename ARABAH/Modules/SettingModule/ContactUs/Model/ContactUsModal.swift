//
//  ContactUsModal.swift
//  ARABAH
//
//  Created by cqlios on 12/12/24.
//

import Foundation


// MARK: - ContactUsModal
struct ContactUsModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: ContactUsModalBody?
}

// MARK: - ContactUsModalBody
struct ContactUsModalBody: Codable {
    let userID, name, email, phone: String?
    let message, countryCode: String?
    let deleted: Bool?
    let id, createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case name, email, phone, message, countryCode, deleted
        case id = "_id"
        case createdAt, updatedAt
        case v = "__v"
    }
}
