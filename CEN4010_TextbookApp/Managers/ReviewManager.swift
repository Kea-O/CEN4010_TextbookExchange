//
//  ReviewManager.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 12/1/25.
//

import Foundation
import FirebaseFirestore

class ReviewManager {
    private let db = Firestore.firestore()
    
    // Submit a new review
    func submitReview(reviewData: Review) async throws -> String {
        guard reviewData.rating >= 1 && reviewData.rating <= 5 else {
            throw NSError(domain: "ReviewManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Rating must be between 1 and 5"])
        }
        
        let reviewedUserId = reviewData.reviewedUserId
        guard !reviewedUserId.isEmpty else {
            throw NSError(domain: "ReviewManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Reviewed user ID is required"])
        }
        
        let reviewRef = db.collection("reviews").document()
        let reviewId = reviewRef.documentID
        
        try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userRef = self.db.collection("users").document(reviewedUserId)

            // Must wrap getDocument in do/catch
            let userDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard userDoc.exists else {
                errorPointer?.pointee = NSError(
                    domain: "ReviewManager",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "User not found"]
                )
                return nil
            }

            let data = userDoc.data() ?? [:]
            let currentRating = data["averageRating"] as? Double ?? 0.0
            let currentReviewCount = data["reviewCount"] as? Int ?? 0
            let newReviewCount = currentReviewCount + 1
            let newAvg =
                ((currentRating * Double(currentReviewCount)) + Double(reviewData.rating))
                / Double(newReviewCount)

            var reviewDict: [String: Any] = [
                "id": reviewId,
                "reviewerId": reviewData.reviewerId,
                "reviewedUserId": reviewedUserId,
                "rating": reviewData.rating,
                "comment": reviewData.comment,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp(),
                "helpful": 0,
                "reported": false
            ]

            if let bookId = reviewData.bookId { reviewDict["bookId"] = bookId }
            if let exId = reviewData.exchangeId { reviewDict["exchangeId"] = exId }

            transaction.setData(reviewDict, forDocument: reviewRef)

            transaction.updateData([
                "averageRating": newAvg,
                "reviewCount": newReviewCount,
                "updatedAt": FieldValue.serverTimestamp()
            ], forDocument: userRef)

            return nil
        })

        return reviewId
    }
    // Get reviews for a specific user
    func getReviewsForUser(userId: String, limitCount: Int = 20) async throws -> [Review] {
        let reviewsRef = db.collection("reviews")
        let query = reviewsRef
            .whereField("reviewedUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limitCount)
        
        let snapshot = try await query.getDocuments()
        var reviews: [Review] = []
        
        for doc in snapshot.documents {
            let data = doc.data()
            guard let reviewerId = data["reviewerId"] as? String,
                  let reviewedUserId = data["reviewedUserId"] as? String,
                  let rating = data["rating"] as? Int,
                  let comment = data["comment"] as? String else { continue }
            
            var review = Review(
                id: doc.documentID,
                reviewerId: reviewerId,
                reviewedUserId: reviewedUserId,
                bookId: data["bookId"] as? String,
                exchangeId: data["exchangeId"] as? String,
                rating: rating,
                comment: comment,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                helpful: data["helpful"] as? Int ?? 0,
                reported: data["reported"] as? Bool ?? false,
                reportReason: data["reportReason"] as? String,
                reportedAt: (data["reportedAt"] as? Timestamp)?.dateValue()
            )
            
            // Fetch reviewer info
            let reviewerRef = db.collection("users").document(review.reviewerId)
            if let reviewerDoc = try? await reviewerRef.getDocument(), reviewerDoc.exists {
                let reviewerData = reviewerDoc.data() ?? [:]
                review.reviewerName = reviewerData["name"] as? String ?? "Unknown User"
                review.reviewerPhoto = reviewerData["photoURL"] as? String
            } else {
                review.reviewerName = "Unknown User"
            }
            
            reviews.append(review)
        }
        
        return reviews
    }
    
    // Get reviews for a specific book
    func getReviewsForBook(bookId: String, limitCount: Int = 20) async throws -> [Review] {
        let reviewsRef = db.collection("reviews")
        let query = reviewsRef
            .whereField("bookId", isEqualTo: bookId)
            .order(by: "createdAt", descending: true)
            .limit(to: limitCount)
        
        let snapshot = try await query.getDocuments()
        var reviews: [Review] = []
        
        for doc in snapshot.documents {
            let data = doc.data()
            guard let reviewerId = data["reviewerId"] as? String,
                  let reviewedUserId = data["reviewedUserId"] as? String,
                  let rating = data["rating"] as? Int,
                  let comment = data["comment"] as? String else { continue }
            
            var review = Review(
                id: doc.documentID,
                reviewerId: reviewerId,
                reviewedUserId: reviewedUserId,
                bookId: data["bookId"] as? String,
                exchangeId: data["exchangeId"] as? String,
                rating: rating,
                comment: comment,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                helpful: data["helpful"] as? Int ?? 0,
                reported: data["reported"] as? Bool ?? false,
                reportReason: data["reportReason"] as? String,
                reportedAt: (data["reportedAt"] as? Timestamp)?.dateValue()
            )
            
            // Fetch reviewer info
            let reviewerRef = db.collection("users").document(review.reviewerId)
            if let reviewerDoc = try? await reviewerRef.getDocument(), reviewerDoc.exists {
                let reviewerData = reviewerDoc.data() ?? [:]
                review.reviewerName = reviewerData["name"] as? String ?? "Unknown User"
                review.reviewerPhoto = reviewerData["photoURL"] as? String
            } else {
                review.reviewerName = "Unknown User"
            }
            
            reviews.append(review)
        }
        
        return reviews
    }
    
    // Get user's average rating
    func getUserRating(userId: String) async throws -> UserRating {
        let userRef = db.collection("users").document(userId)
        let userDoc = try await userRef.getDocument()
        
        guard userDoc.exists else {
            return UserRating(averageRating: 0, reviewCount: 0)
        }
        
        let userData = userDoc.data() ?? [:]
        return UserRating(
            averageRating: userData["averageRating"] as? Double ?? 0.0,
            reviewCount: userData["reviewCount"] as? Int ?? 0
        )
    }
    
    // Update an existing review
    func updateReview(reviewId: String, rating: Int?, comment: String?) async throws {
        guard let rating = rating, rating >= 1 && rating <= 5 else {
            throw NSError(domain: "ReviewManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Rating must be between 1 and 5"])
        }

        let reviewRef = db.collection("reviews").document(reviewId)
        let reviewDoc = try await reviewRef.getDocument()

        guard reviewDoc.exists else {
            throw NSError(domain: "ReviewManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Review not found"])
        }

        let reviewData = reviewDoc.data() ?? [:]
        let oldRating = reviewData["rating"] as? Int ?? 0
        guard let reviewedUserId = reviewData["reviewedUserId"] as? String else {
            throw NSError(domain: "ReviewManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid review data"])
        }

        try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userRef = self.db.collection("users").document(reviewedUserId)

            // non-throwing version
            let userDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            if userDoc.exists && rating != oldRating {
                let data = userDoc.data() ?? [:]
                let currentRating = data["averageRating"] as? Double ?? 0.0
                let reviewCount = data["reviewCount"] as? Int ?? 1

                let newAvg = (
                    (currentRating * Double(reviewCount))
                    - Double(oldRating)
                    + Double(rating)
                ) / Double(reviewCount)

                transaction.updateData([
                    "averageRating": newAvg,
                    "updatedAt": FieldValue.serverTimestamp()
                ], forDocument: userRef)
            }

            var updateData: [String: Any] = [
                "updatedAt": FieldValue.serverTimestamp(),
                "rating": rating
            ]

            if let newComment = comment {
                updateData["comment"] = newComment
            }

            transaction.updateData(updateData, forDocument: reviewRef)

            return nil
        })
    }
    // Mark a review as helpful
    func markReviewHelpful(reviewId: String) async throws {
        let reviewRef = db.collection("reviews").document(reviewId)
        try await reviewRef.updateData([
            "helpful": FieldValue.increment(Int64(1))
        ])
    }
    
    // Report a review
    func reportReview(reviewId: String, reportReason: String) async throws {
        let reviewRef = db.collection("reviews").document(reviewId)
        try await reviewRef.updateData([
            "reported": true,
            "reportReason": reportReason,
            "reportedAt": FieldValue.serverTimestamp()
        ])
    }
    
    // Check if a user can review another user for a specific exchange
    func checkCanReview(reviewerId: String, reviewedUserId: String, exchangeId: String) async throws -> (canReview: Bool, reason: String?) {
        if reviewerId == reviewedUserId {
            return (false, "Cannot review yourself")
        }
        
        let reviewsRef = db.collection("reviews")
        let query = reviewsRef
            .whereField("reviewerId", isEqualTo: reviewerId)
            .whereField("exchangeId", isEqualTo: exchangeId)
        
        let snapshot = try await query.getDocuments()
        
        if !snapshot.isEmpty {
            return (false, "Already reviewed this exchange")
        }
        
        return (true, nil)
    }
    
    // Check if reviewer has already reviewed this user (any exchange)
    func hasUserReviewed(reviewerId: String, reviewedUserId: String) async throws -> Bool {
        let reviewsRef = db.collection("reviews")
        let query = reviewsRef
            .whereField("reviewerId", isEqualTo: reviewerId)
            .whereField("reviewedUserId", isEqualTo: reviewedUserId)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        return !snapshot.isEmpty
    }
}

