//
//  MockData.swift
//  CEN4010_TextbookApp
//
//  Mock data for development and testing when Firebase is unavailable
//

import Foundation

extension User {
    static var mockUsers: [User] {
        [
            User(id: nil, name: "Alex Johnson", email: "alex.johnson@university.edu"),
            User(id: nil, name: "Sarah Chen", email: "sarah.chen@university.edu"),
            User(id: nil, name: "Michael Rodriguez", email: "michael.r@university.edu"),
            User(id: nil, name: "Emily Davis", email: "emily.davis@university.edu"),
            User(id: nil, name: "James Wilson", email: "james.wilson@university.edu"),
            User(id: nil, name: "Demo Seller", email: "demo@university.edu")
        ]
    }
    
    static var alex: User {
        mockUsers[0]
    }
    
    static var sarah: User {
        mockUsers[1]
    }
    
    static var michael: User {
        mockUsers[2]
    }
    
    static var emily: User {
        mockUsers[3]
    }
    
    static var james: User {
        mockUsers[4]
    }
}

extension Post {
    static var mockPosts: [Post] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            // Alex's posts
            Post(
                id: "mock-post-001",
                user_id: "alex-johnson-001",
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                title: "Calculus: Early Transcendentals",
                author: "Stewart",
                edition: "9th",
                isbn: "978-1-337-55828-9",
                subject: Subject.MathematicsStatistics.rawValue,
                price: 85.00,
                locations: "Library or Engineering Atrium",
                times: "Weekdays after 3 PM",
                condition: Condition.Good.rawValue,
                image_url: "https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400"
            ),
            Post(
                id: "mock-post-002",
                user_id: "alex-johnson-001",
                timestamp: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                title: "Introduction to Algorithms",
                author: "Cormen, Leiserson, Rivest, Stein",
                edition: "4th",
                isbn: "978-0-262-04630-5",
                subject: Subject.ComputerInformationTechnologies.rawValue,
                price: 120.00,
                locations: "Student Union",
                times: "Anytime",
                condition: Condition.Good.rawValue,
                image_url: "https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400"
            ),
            
            // Sarah's posts
            Post(
                id: "mock-post-003",
                user_id: "sarah-chen-001",
                timestamp: calendar.date(byAdding: .hour, value: -5, to: now) ?? now,
                title: "Organic Chemistry",
                author: "Wade",
                edition: "9th",
                isbn: "978-0-13-416037-5",
                subject: Subject.NaturalSciences.rawValue,
                price: 95.00,
                locations: "Chemistry Building Lobby",
                times: "Monday-Friday 10 AM - 2 PM",
                condition: Condition.Fair.rawValue,
                image_url: "https://images.unsplash.com/photo-1532619675605-1ede6c4ed944?w=400"
            ),
            Post(
                id: "mock-post-004",
                user_id: "sarah-chen-001",
                timestamp: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                title: "Biology: Concepts and Connections",
                author: "Campbell, Reece",
                edition: "8th",
                isbn: "978-0-13-429601-2",
                subject: Subject.HealthLifeSciences.rawValue,
                price: 75.00,
                locations: "Science Library",
                times: "Weekends preferred",
                condition: Condition.Good.rawValue,
                image_url: "https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400"
            ),
            
            // Michael's posts
            Post(
                id: "mock-post-005",
                user_id: "michael-rodriguez-001",
                timestamp: calendar.date(byAdding: .hour, value: -1, to: now) ?? now,
                title: "Fundamentals of Physics",
                author: "Halliday, Resnick, Walker",
                edition: "11th",
                isbn: "978-1-119-77351-1",
                subject: Subject.EngineeringAppliedSciences.rawValue,
                price: 110.00,
                locations: "Physics Building or Engineering Quad",
                times: "Afternoons",
                condition: Condition.Good.rawValue,
                image_url: "https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400"
            ),
            Post(
                id: "mock-post-006",
                user_id: "michael-rodriguez-001",
                timestamp: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                title: "Linear Algebra and Its Applications",
                author: "Lay, Lay, McDonald",
                edition: "6th",
                isbn: "978-0-13-585125-8",
                subject: Subject.MathematicsStatistics.rawValue,
                price: 90.00,
                locations: "Math Building",
                times: "Flexible",
                condition: Condition.Fair.rawValue,
                image_url: "https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400"
            ),
            
            // Emily's posts
            Post(
                id: "mock-post-007",
                user_id: "emily-davis-001",
                timestamp: calendar.date(byAdding: .hour, value: -3, to: now) ?? now,
                title: "Principles of Marketing",
                author: "Kotler, Armstrong",
                edition: "18th",
                isbn: "978-0-13-449251-3",
                subject: Subject.BusinessManagement.rawValue,
                price: 80.00,
                locations: "Business School",
                times: "Weekdays 9 AM - 5 PM",
                condition: Condition.Good.rawValue,
                image_url: "https://images.unsplash.com/photo-1532619675605-1ede6c4ed944?w=400"
            ),
            Post(
                id: "mock-post-008",
                user_id: "emily-davis-001",
                timestamp: calendar.date(byAdding: .day, value: -4, to: now) ?? now,
                title: "Introduction to Psychology",
                author: "Myers, DeWall",
                edition: "13th",
                isbn: "978-1-319-38100-0",
                subject: Subject.SocialSciences.rawValue,
                price: 70.00,
                locations: "Psychology Building",
                times: "By appointment",
                condition: Condition.Poor.rawValue,
                image_url: "https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400"
            ),
            
            // James's posts
            Post(
                id: "mock-post-009",
                user_id: "james-wilson-001",
                timestamp: calendar.date(byAdding: .hour, value: -6, to: now) ?? now,
                title: "Data Structures and Algorithms in Java",
                author: "Goodrich, Tamassia, Goldwasser",
                edition: "6th",
                isbn: "978-1-118-77133-4",
                subject: Subject.ComputerInformationTechnologies.rawValue,
                price: 100.00,
                locations: "Computer Science Building",
                times: "Evenings",
                condition: Condition.Good.rawValue,
                image_url: "https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400"
            ),
            Post(
                id: "mock-post-010",
                user_id: "james-wilson-001",
                timestamp: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                title: "Database System Concepts",
                author: "Silberschatz, Korth, Sudarshan",
                edition: "7th",
                isbn: "978-0-07-352332-3",
                subject: Subject.ComputerInformationTechnologies.rawValue,
                price: 115.00,
                locations: "CS Building or Library",
                times: "Weekends",
                condition: Condition.Good.rawValue,
                image_url: "https://images.unsplash.com/photo-1532619675605-1ede6c4ed944?w=400"
            ),
            
            // Demo user posts
            Post(
                id: "mock-post-011",
                user_id: "demo-user-001",
                timestamp: calendar.date(byAdding: .hour, value: -4, to: now) ?? now,
                title: "Introduction to Statistics",
                author: "Moore, Notz, Fligner",
                edition: "5th",
                isbn: "978-1-319-27877-1",
                subject: Subject.MathematicsStatistics.rawValue,
                price: 65.00,
                locations: "Math Building or Student Center",
                times: "Anytime",
                condition: Condition.Fair.rawValue,
                image_url: "https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400"
            ),
            Post(
                id: "mock-post-012",
                user_id: "demo-user-001",
                timestamp: calendar.date(byAdding: .day, value: -6, to: now) ?? now,
                title: "Microeconomics: Principles and Applications",
                author: "Hall, Lieberman",
                edition: "6th",
                isbn: "978-1-305-58512-5",
                subject: Subject.BusinessManagement.rawValue,
                price: 55.00,
                locations: "Economics Building",
                times: "Weekdays",
                condition: Condition.Poor.rawValue,
                image_url: "https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400"
            )
        ]
    }
}

// Helper to get user ID from user name for mock data
extension User {
    var mockUserID: String {
        switch name {
        case "Alex Johnson": return "alex-johnson-001"
        case "Sarah Chen": return "sarah-chen-001"
        case "Michael Rodriguez": return "michael-rodriguez-001"
        case "Emily Davis": return "emily-davis-001"
        case "James Wilson": return "james-wilson-001"
        case "Demo Seller": return "demo-user-001"
        default: return "unknown-user"
        }
    }
}

// Mock data for messages and conversations
extension Conversation {
    static var mockConversations: [Conversation] {
        let now = Date()
        let calendar = Calendar.current
        
        return [
            Conversation(
                id: "alex-johnson-001_demo-user-001",
                participant1Id: "alex-johnson-001",
                participant2Id: "demo-user-001",
                lastMessage: "Sounds good! I can meet you tomorrow.",
                lastMessageTimestamp: calendar.date(byAdding: .hour, value: -1, to: now),
                postId: "mock-post-001"
            ),
            Conversation(
                id: "sarah-chen-001_demo-user-001",
                participant1Id: "demo-user-001",
                participant2Id: "sarah-chen-001",
                lastMessage: "Is the book still available?",
                lastMessageTimestamp: calendar.date(byAdding: .hour, value: -3, to: now),
                postId: "mock-post-003"
            )
        ]
    }
}

extension Message {
    static var mockMessages: [Message] {
        let now = Date()
        let calendar = Calendar.current
        
        return [
            // Conversation between Demo and Alex
            Message(
                id: "msg-001",
                conversationId: "alex-johnson-001_demo-user-001",
                senderId: "demo-user-001",
                receiverId: "alex-johnson-001",
                text: "Hi! Is the Calculus textbook still available?",
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                isRead: true
            ),
            Message(
                id: "msg-002",
                conversationId: "alex-johnson-001_demo-user-001",
                senderId: "alex-johnson-001",
                receiverId: "demo-user-001",
                text: "Yes, it is! Are you interested?",
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                isRead: true
            ),
            Message(
                id: "msg-003",
                conversationId: "alex-johnson-001_demo-user-001",
                senderId: "demo-user-001",
                receiverId: "alex-johnson-001",
                text: "Great! Can we meet at the library?",
                timestamp: calendar.date(byAdding: .hour, value: -1, to: now) ?? now,
                isRead: true
            ),
            Message(
                id: "msg-004",
                conversationId: "alex-johnson-001_demo-user-001",
                senderId: "alex-johnson-001",
                receiverId: "demo-user-001",
                text: "Sounds good! I can meet you tomorrow.",
                timestamp: calendar.date(byAdding: .hour, value: -1, to: now) ?? now,
                isRead: false
            ),
            
            // Conversation between Demo and Sarah
            Message(
                id: "msg-005",
                conversationId: "sarah-chen-001_demo-user-001",
                senderId: "demo-user-001",
                receiverId: "sarah-chen-001",
                text: "Is the book still available?",
                timestamp: calendar.date(byAdding: .hour, value: -3, to: now) ?? now,
                isRead: true
            )
        ]
    }
}

