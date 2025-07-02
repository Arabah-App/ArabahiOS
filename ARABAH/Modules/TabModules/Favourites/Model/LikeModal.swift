//
//  LikeModal.swift
//  ARABAH
//
//  Created by cql71 on 10/01/25.
//

import Foundation

// MARK: - LikeModal
struct LikeModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: LikeModalBody?
}

// MARK: - LikeModalBody
struct LikeModalBody: Codable {
    let id, userID: String?
    let status: Int?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case status, deleted, createdAt, updatedAt
        case v = "__v"
    }
}
