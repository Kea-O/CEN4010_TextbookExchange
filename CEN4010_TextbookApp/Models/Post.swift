//
//  Post.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/18/25.
//
import Foundation
import FirebaseFirestore


// Create a model for the posts about textbooks. We'll need an ID (provided by Firebase), a download URL for the given image, the seller's userID, texbook name, author, edition, condition, isbn, subject (such as engineering, biology, etc), price, meetup locations, meetup times, and date posted (which is recorded automatically by AppWrite).
// The struct should also conform to Identifiable and Codable so that we can code/decode them into/from a JSON and loop through them.
struct Post: Identifiable, Codable, Equatable {
    // Firebase auto-generates an id string:
    @DocumentID var id: String?
    
    // metadata for the userID of the uploader and time posted. Timestamp is automatically filled on instance creation.
    var user_id: String
    var timestamp: Date = Date()
    
    // Values describing the textbook::
    var title: String
    var author: String
    var edition: String
    var isbn: String
    var subject: String
    var price: Double
    var locations: String
    var times: String
    var condition: String
    
    // URL to display the image:
    var image_url: String
}

// Because both subject and condition are enums, we'll need to hardcode their values so that we can put them into a drop-down for the user to select from:
enum Subject: String, CaseIterable, Identifiable {
    case ArtsHumanities = "Arts & Humanities"
    case SocialSciences = "Social sciences"
    case NaturalSciences = "Natural Sciences"
    case MathematicsStatistics = "Mathematics & Statistics"
    case ComputerInformationTechnologies = "Computer & Information Technologies"
    case HealthLifeSciences = "Health & Life Sciences"
    case BusinessManagement = "Business & Management"
    case LawPublicPolicy = "Law & Public Policy"
    case EngineeringAppliedSciences = "Engineering & Applied Sciences"
    case ArchitectureDesign = "Architecture & Design"
    case AgriculturalEnvironmentalSciences = "Agricultural & Environmental Sciences"
    
    // Make sure each case has an id value:
    var id: String { self.rawValue }
}

// Create the enums for the condition of the textbook; good, fair, or poor quality.
enum Condition: String, CaseIterable, Identifiable {
    case Good = "Good"
    case Fair = "Fair"
    case Poor = "Poor"
    
    // Add an id for each case:
    var id: String {self.rawValue}
}

