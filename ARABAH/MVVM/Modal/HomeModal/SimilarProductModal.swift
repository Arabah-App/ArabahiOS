//
//  SimilarProductModal.swift
//  ARABAH
//
//  Created by cql71 on 06/03/25.
//

//import Foundation
//
//// MARK: - SimilarProductModal
//struct SimilarProductModal: Codable {
//    let success: Bool?
//    let code: Int?
//    let message: String?
//    let body: [SimilarProductModalBody]?
//}
//
//// MARK: - SimilarProductModalBody
//struct SimilarProductModalBody: Codable {
//    let id, userID, categoryNames, brandname: String?
//    let brandnameArabic, name, nameArabic, description: String?
//    let descriptionArabic, price, image, qrCode: String?
//    let prodiuctUnit, prodiuctUnitArabic: String?
//    let product: [Product]?
//    let deleted: Bool?
//    let updatedList: [String]?
//    var createdAt, updatedAt: String?
//    let v: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case userID = "userId"
//        case categoryNames
//        case brandname = "Brandname"
//        case brandnameArabic = "BrandnameArabic"
//        case name, nameArabic, description, descriptionArabic, price, image, qrCode
//        case prodiuctUnit = "ProdiuctUnit"
//        case prodiuctUnitArabic = "ProdiuctUnitArabic"
//        case product, deleted, updatedList, createdAt, updatedAt
//        case v = "__v"
//    }
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decodeIfPresent(String.self, forKey: .id)
//        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
//        self.categoryNames = try container.decodeIfPresent(String.self, forKey: .categoryNames)
//        self.brandname = try container.decodeIfPresent(String.self, forKey: .brandname)
//        self.brandnameArabic = try container.decodeIfPresent(String.self, forKey: .brandnameArabic)
//        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
//        
//        let currentLang = L102Language.currentAppleLanguageFull()
//        switch currentLang {
//        case "ar":
//            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
//            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
//        default:
//            self.name = try container.decodeIfPresent(String.self, forKey: .name)
//        }
//        
//        self.description = try container.decodeIfPresent(String.self, forKey: .description)
//        self.descriptionArabic = try container.decodeIfPresent(String.self, forKey: .descriptionArabic)
//        self.price = try container.decodeIfPresent(String.self, forKey: .price)
//        self.image = try container.decodeIfPresent(String.self, forKey: .image)
//        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
//        self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
//        self.prodiuctUnitArabic = try container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic)
//        self.product = try container.decodeIfPresent([Product].self, forKey: .product)
//        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
//        self.updatedList = try container.decodeIfPresent([String].self, forKey: .updatedList)
//        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
////        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
//        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt),
//           let updatedAtInt = Int(updatedAtString) {
//            self.updatedAt = String(updatedAtInt)
//        } else {
//            self.updatedAt = nil  // Handle invalid or missing values gracefully
//        }
//        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
//    }
//}
//import Foundation
//
//// MARK: - SimilarProductModal
//struct SimilarProductModal: Codable {
//    let success: Bool?
//    let code: Int?
//    let message: String?
//    let body: [SimilarProductModalBody]?
//}
//
//// MARK: - SimilarProductModalBody
//struct SimilarProductModalBody: Codable {
//    let id, userID, categoryNames, brandname: String?
//    let brandnameArabic, name, nameArabic, description: String?
//    let descriptionArabic: String?
//    let price: Int?
//    let image, qrCode: String?
//    var prodiuctUnit, prodiuctUnitArabic: String?
//    let product: [Product]?
//    let deleted: Bool?
//    let updatedList: [Product]?
//    let createdAt, updatedAt: String?
//    let v: Int?
//    let brandID: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case userID = "userId"
//        case categoryNames
//        case brandname = "Brandname"
//        case brandnameArabic = "BrandnameArabic"
//        case name, nameArabic, description, descriptionArabic, price, image, qrCode
//        case prodiuctUnit = "ProdiuctUnit"
//        case prodiuctUnitArabic = "ProdiuctUnitArabic"
//        case product, deleted, updatedList, createdAt, updatedAt
//        case v = "__v"
//        case brandID = "BrandID"
//    }
//    
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decodeIfPresent(String.self, forKey: .id)
//        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
//        self.categoryNames = try container.decodeIfPresent(String.self, forKey: .categoryNames)
//        self.brandname = try container.decodeIfPresent(String.self, forKey: .brandname)
//        self.brandnameArabic = try container.decodeIfPresent(String.self, forKey: .brandnameArabic)
//        self.name = try container.decodeIfPresent(String.self, forKey: .name)
//        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
//        self.description = try container.decodeIfPresent(String.self, forKey: .description)
//        self.descriptionArabic = try container.decodeIfPresent(String.self, forKey: .descriptionArabic)
//        self.price = try container.decodeIfPresent(Int.self, forKey: .price)
//        self.image = try container.decodeIfPresent(String.self, forKey: .image)
//        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
//        if let prodiuctUnit = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnit) {
//            self.prodiuctUnit = prodiuctUnit
//        }
//        if let prodiuctUnitArabic = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic) {
//            self.prodiuctUnitArabic = prodiuctUnitArabic
//        }
//        self.product = try container.decodeIfPresent([Product].self, forKey: .product)
//        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
//        self.updatedList = try container.decodeIfPresent([Product].self, forKey: .updatedList)
//        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
//        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
//        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
//        self.brandID = try container.decodeIfPresent(String.self, forKey: .brandID)
//    }
//}
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - SimilarProductModal
struct SimilarProductModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [SimilarProductModalBody]?
}

// MARK: - SimilarProductModalBody
struct SimilarProductModalBody: Codable {
    let id, userID, categoryNames, brandID: String?
    let name, nameArabic, description, descriptionArabic: String?
    let price: Int?
    let image, barCode: String?
    let productUnitID: ProductUnitID?
    let product: [Product]?
    let deleted: Bool?
    let updatedList: [Product]?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case categoryNames
        case brandID = "BrandID"
        case name, nameArabic, description, descriptionArabic, price, image
        case barCode = "BarCode"
        case productUnitID = "productUnitId"
        case product, deleted, updatedList, createdAt, updatedAt
        case v = "__v"
    }
}

// MARK: - ProductUnitID
struct ProductUnitID: Codable {
    var id, prodiuctUnit, prodiuctUnitArabic: String?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case prodiuctUnit = "ProdiuctUnit"
        case prodiuctUnitArabic = "ProdiuctUnitArabic"
        case deleted, createdAt, updatedAt
        case v = "__v"
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
        self.prodiuctUnitArabic = try container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic)
        
        if let prodiuctUnit = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnit) {
            self.prodiuctUnit = prodiuctUnit
        }

        if let prodiuctUnitArabic = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic) {
            self.prodiuctUnitArabic = prodiuctUnitArabic
        }
        
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
    }
}
