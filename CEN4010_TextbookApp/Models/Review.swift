//
//  Review.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 12/1/25.
//

import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var reviewerId: String
    var reviewedUserId: String
    var bookId: String?
    var exchangeId: String?
    var rating: Int // 1-5 stars
    var comment: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var helpful: Int = 0
    var reported: Bool = false
    var reportReason: String?
    var reportedAt: Date?
    
    // Computed properties for reviewer info (populated when fetching)
    var reviewerName: String?
    var reviewerPhoto: String?
}

// Helper struct for user rating summary
struct UserRating {
    var averageRating: Double
    var reviewCount: Int
}


