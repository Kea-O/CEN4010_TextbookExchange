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
    static var demo: User {
        User(
            id: "demo-user-001",
            name: "Demo Seller",
            email: "demo@university.edu",
        )
    }
}
