//
//  User.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import Foundation
import FirebaseFirestore

// Have a user model for people logging on and posting/messaging
struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    
    // A fake user for testing Firebase and UI previews
    // Note: The id is set to nil to avoid Firestore warnings.
    // For demo filtering, use user_id field in posts instead of user.id
    static var demo: User {
        User(
            id: nil,
            name: "Demo Seller",
            email: "demo@university.edu"
        )
    }
    
    // Helper property for demo/mock user ID used in filtering
    var demoID: String? {
        if let id = id {
            return id
        }
        // Return mock user ID if this is a mock user
        return mockUserID != "unknown-user" ? mockUserID : (name == "Demo Seller" ? "demo-user-001" : nil)
    }
}
