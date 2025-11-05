//
//  PostDetailView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    
    private var currencyFormatter: String {
        post.price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                metadataSection
                meetupSection
            }
            .padding()
        }
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.author)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(currencyFormatter)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.green)
            if let edition = post.edition, !edition.isEmpty {
                Text("Edition: \(edition)")
            }
            if let isbn = post.isbn, !isbn.isEmpty {
                Text("ISBN: \(isbn)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Subject: \(post.subject)", systemImage: "books.vertical")
            Label("Condition: \(post.condition)", systemImage: "shippingbox.fill")
            Label("Listed: \(post.timestamp.formatted(date: .abbreviated, time: .shortened))", systemImage: "clock.fill")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var meetupSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pickup Details")
                .font(.headline)
            Text("Locations")
                .font(.subheadline.weight(.semibold))
            Text(post.locations)
            Divider()
            Text("Times")
                .font(.subheadline.weight(.semibold))
            Text(post.times)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let sample = Post(
        user_id: "demo-user-001",
        title: "Calculus: Early Transcendentals",
        author: "Stewart",
        edition: "9th",
        isbn: "978-1-337-55828-9",
        subject: Subject.MathematicsStatistics.rawValue,
        price: 85.0,
        locations: "Library or Engineering Atrium",
        times: "Weekdays after 3 PM",
        condition: Condition.Good.rawValue,
        image_url: "https://example.com"
    )
    PostDetailView(post: sample)
}