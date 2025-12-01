//
//  ReviewView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 12/3/25.
//
import SwiftUI

struct LeaveReviewView: View {
    let currentUser: AppUser
    let reviewedUser: AppUser

    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private let reviewManager = ReviewManager()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Rate \(reviewedUser.name)")) {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    rating = star
                                }
                        }
                    }
                }

                Section(header: Text("Comment (optional)")) {
                    TextField("Write a short review…", text: $comment, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            .navigationTitle("Leave a Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        Task { await submitReview() }
                    }
                    .disabled(isSubmitting || (currentUser.id ?? "").isEmpty || (reviewedUser.id ?? "").isEmpty)
                }
            }
        }
    }

    private func submitReview() async {
        guard let reviewerId = currentUser.id,
              let reviewedId = reviewedUser.id else {
            errorMessage = "Missing user IDs."
            return
        }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            // NEW: block duplicate reviews
            let alreadyReviewed = try await reviewManager.hasUserReviewed(
                reviewerId: reviewerId,
                reviewedUserId: reviewedId
            )
            if alreadyReviewed {
                errorMessage = "You’ve already reviewed this user."
                return
            }

            let review = Review(
                id: nil,
                reviewerId: reviewerId,
                reviewedUserId: reviewedId,
                bookId: nil,
                exchangeId: nil,
                rating: rating,
                comment: comment
            )

            _ = try await reviewManager.submitReview(reviewData: review)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
