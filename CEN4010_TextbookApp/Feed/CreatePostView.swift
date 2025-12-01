//
//  CreatePostView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/28/25.
//

import SwiftUI
// For managing images, we'll need:
import UIKit

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var betweenPost: PostBetweenView
    
    let user: AppUser
    
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
    
    // Create some variables to help with the user uploading their image of the textbook:
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    
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
                
                Section("Image") {
                    VStack {
                        if let image = selectedImage {
                            // Show preview
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(10)
                                .padding(.vertical)
                            
                            Button("Remove Image") {
                                selectedImage = nil
                            }
                            .foregroundColor(.red)
                            
                        } else {
                            // Button to select image
                            Button("Select Image") {
                                showImagePicker = true
                            }
                        }
                    }
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
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
        guard requiredFields.allSatisfy({ !$0.isEmpty }), selectedImage != nil else {
            presentError("Please fill out all fields before posting.")
            return
        }
        
        guard let priceValue = Double(trimmedPrice) else {
            presentError("Enter a valid numeric price.")
            return
        }
        
        // First, we need to upload the image and get the URL back. But Firebase expects a JPEG image, and the function expects the data from that image. So we'll need to covnert the image to JPEG data. We'll use a 0.6 compressionQuality so it'll use less data but still be viewable.
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.6) else { return }
        
        // Now we'll create a variable to contain the URL of the image
        let ImageURL: String
        
        // Call the function and get the URL:
        do {
            ImageURL = try await betweenPost.saveImage(data: imageData, ID: userId)
        } catch {
            presentError("Image upload failed: \(error.localizedDescription)")
            return
        }
        
        // Now we make a Post instance for this new post
        let newPost = Post(
            user_id: userId,
            title: trimmedTitle,
            author: trimmedAuthor,
            edition: trimmedEdition,
            isbn: trimmedISBN,
            subject: selectedSubject.rawValue,
            price: priceValue,
            locations: trimmedLocations,
            times: trimmedTimes,
            condition: selectedCondition.rawValue,
            image_url: ImageURL
        )
        
        // Send this post instance into Firestore:
        do {
            try await betweenPost.create(post: newPost)
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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let edited = info[.editedImage] as? UIImage {
                parent.image = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.image = original
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
