//
//  GetNotesModal.swift
//  ARABAH
//
//  Created by cql71 on 28/01/25.
//

import Foundation

//// MARK: - GetNotesModal
//struct GetNotesModal: Codable {
//    let success: Bool?
//    let code: Int?
//    let message: String?
//    let body: [GetNotesModalBody]?
//}
//
//// MARK: - GetNotesModalBody
//struct GetNotesModalBody: Codable {
//    let id, userID, updatedAt: String?
//    var notesText: [NotesText]?
//    let v: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case userID = "userId"
//        case notesText, updatedAt
//        case v = "__v"
//    }
//}
//import Foundation

// MARK: - GetNotesModal
struct GetNotesModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [GetNotesModalBody]?
}

// MARK: - GetNotesModalBody
struct GetNotesModalBody: Codable {
    let id, userID, createdAt, updatedAt: String?
    let notesText: [NotesText]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case createdAt, updatedAt, notesText
    }
}
