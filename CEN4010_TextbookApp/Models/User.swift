//
//  User.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import Foundation
import FirebaseFirestore

// Have a user model for people logging on and posting/messaging. We'll containt their id, name and email.
struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    
    // Demo user for previews/testing
    static var demo: AppUser {
        AppUser(
            id: "demo-user-001",
            name: "Demo Seller",
            email: "demo@university.edu"
        )
    }
    
    // Mock users for testing (if needed)
    static var mockUsers: [AppUser] {
        [
            AppUser(id: "alex-johnson-001", name: "Alex Johnson", email: "alex@university.edu"),
            AppUser(id: "sarah-chen-001", name: "Sarah Chen", email: "sarah@university.edu"),
            AppUser(id: "michael-rodriguez-001", name: "Michael Rodriguez", email: "michael@university.edu"),
            AppUser(id: "emily-davis-001", name: "Emily Davis", email: "emily@university.edu"),
            AppUser(id: "james-wilson-001", name: "James Wilson", email: "james@university.edu"),
            demo
        ]
    }
    
    // Computed property for demo ID (for backward compatibility)
    var demoID: String? {
        id
    }
}
