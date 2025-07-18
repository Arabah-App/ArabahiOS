//
//  TermsPrivacyMdoal.swift
//  ARABAH
//
//  Created by cqlios on 10/12/24.
//

import Foundation

// MARK: - TermsPrivacyMdoal
struct TermsPrivacyMdoal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: TermsPrivacyMdoalBody?
}

// MARK: - TermsPrivacyMdoalBody
struct TermsPrivacyMdoalBody: Codable {
    let id: String?
    let type: Int?
    var title, description,descriptionArabic, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, title, description, updatedAt, descriptionArabic
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.type = try container.decodeIfPresent(Int.self, forKey: .type)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicDescription = try container.decodeIfPresent(String.self, forKey: .descriptionArabic)
            self.description = (arabicDescription?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .description) : arabicDescription
        default:
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
        }
    }
}
