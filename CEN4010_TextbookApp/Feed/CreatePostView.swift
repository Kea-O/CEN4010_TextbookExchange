//
//  CreatePostView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: PostBetweenView
    
    let user: User
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var edition: String = ""
    @State private var isbn: String = ""
    @State private var selectedSubject: Subject = .ComputerInformationTechnologies
    @State private var selectedCondition: Condition = .Good
    @State private var price: String = ""
    @State private var locations: String = ""
    @State private var times: String = ""
    
    @State private var isSaving = false
    @State private var showErrorAlert = false
    @State private var localErrorMessage: String = ""
    
    private var formIsValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEdition = edition.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedISBN = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrice = price.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocations = locations.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTimes = times.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty,
              !trimmedAuthor.isEmpty,
              !trimmedEdition.isEmpty,
              !trimmedISBN.isEmpty,
              !trimmedPrice.isEmpty,
              Double(trimmedPrice) != nil,
              !trimmedLocations.isEmpty,
              !trimmedTimes.isEmpty,
              user.id != nil else {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Book Info") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Edition", text: $edition)
                    TextField("ISBN", text: $isbn)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
                
                Section("Category") {
                    Picker("Subject", selection: $selectedSubject) {
                        ForEach(Subject.allCases) { subject in
                            Text(subject.rawValue).tag(subject)
                        }
                    }
                    Picker("Condition", selection: $selectedCondition) {
                        ForEach(Condition.allCases) { condition in
                            Text(condition.rawValue).tag(condition)
                        }
                    }
                }
                
                Section("Meetup Details") {
                    TextField("Locations", text: $locations, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                    TextField("Times", text: $times, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                }
                
                Section {
                    Button {
                        Task { await savePost() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save Post")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSaving)
                }
            }
            .alert("Unable to create post", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(localErrorMessage)
            }
        }
    }
    
    private func savePost() async {
        guard let userId = user.id else {
            presentError("User ID missing. Try signing in again.")
            return
        }

        isSaving = true
        defer { isSaving = false }
        
        let trimmedEdition = edition.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedISBN = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocations = locations.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTimes = times.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrice = price.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ensure all fields are filled before attempting to save
        let requiredFields = [trimmedTitle, trimmedAuthor, trimmedEdition, trimmedISBN, trimmedPrice, trimmedLocations, trimmedTimes]
        guard requiredFields.allSatisfy({ !$0.isEmpty }) else {
            presentError("Please fill out all fields before posting.")
            return
        }
        
        guard let priceValue = Double(trimmedPrice) else {
            presentError("Enter a valid numeric price.")
            return
        }
        
        let placeholderImageURL = ""
        
        let newPost = Post(
            user_id: userId,
            title: trimmedTitle,
            author: trimmedAuthor,
            edition: trimmedEdition.isEmpty ? nil : trimmedEdition,
            isbn: trimmedISBN.isEmpty ? nil : trimmedISBN,
            subject: selectedSubject.rawValue,
            price: priceValue,
            locations: trimmedLocations,
            times: trimmedTimes,
            condition: selectedCondition.rawValue,
            image_url: placeholderImageURL
        )
        
        do {
            try await viewModel.create(post: newPost)
            dismiss()
        } catch {
            presentError(error.localizedDescription)
        }
    }
    
    private func presentError(_ message: String) {
        localErrorMessage = message
        showErrorAlert = true
    }
}

#Preview {
    CreatePostView(user: .demo)
        .environmentObject(PostBetweenView())
}

