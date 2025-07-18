//
//  CategoryListModal.swift
//  ARABAH
//
//  Created by cql71 on 16/01/25.
//

import Foundation

// MARK: - CategoryListModal
struct CategoryListModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: CategoryListModalBody?
}

// MARK: - CategoryListModalBody
struct CategoryListModalBody: Codable {
    let category: [Categorys]?

    enum CodingKeys: String, CodingKey {
        case category = "Category"
    }
}
