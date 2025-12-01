//
//  FeedManager.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 11/18/25.
//
import Foundation
import FirebaseFirestore
import FirebaseStorage

// We need to create a manager of the post feed to create useful functions (such as fetch/get posts) that we can call in the actual FeedView.
class PostManager {
    // Add instances of Firestore and storage to interact with the Firestore database and storage
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Create a function for fetching the textbook posts. Firestore is asynchronous and can throw an error, so we need to account for that with async throws, and using try and await in the actual firestore database calls. -> [Post] is saying that the returned data is in a Post model.
    func fetchPost() async throws -> [Post] {
        // Access the database and the collection storing the post data
        let data = try await db.collection("TextbookPosts")
            // sort the data by newest first:
            .order(by: "timestamp", descending: true)
            // use .getDocuments() to send a request through the db connection for post data. This is a snapshot, so the feed will not be constantly updating.
            .getDocuments()
        
        // If there was no error, we'll get the posts from the snapshot of the data, and turn the Firestore data into our Post model. We're able to do this via doc.data(as:) because the model conforms to Codable. CompactMap makes it so that if decoding fails, there's no nils to crash the app.
        return data.documents.compactMap { doc in
            try? doc.data(as: Post.self)
        }
    }
    
    // Create a function for creating posts. We'll make the input a Post, which means we'll need to create the Post instance before using this function, which is fine because Post wants a image URL, so we'll need to upload an image to Firebase first.
    func createPost(post: Post) async throws {
        // Create a mutable copy without the DocumentID to avoid encoding issues
        var postToCreate = post
        postToCreate.id = nil
        try db.collection("TextbookPosts").addDocument(from: postToCreate)
    }
    
    // Make a function that uploads the user-given image of the textbook to Firebase. We'll be taking in the raw image data (usually a JPEG) and an ID to name the image file in Firebase Storage.
    func uploadImage(imageData: Data, postID: String) async throws -> String {
        // Create a reference path for the image file in firebase storage; Firebase Storage works like a cloud system, so we need a name for the file we're uploading.
        let path = storage.reference().child("PostImages/\(postID)")
        
        // We'll need to tell Firebase Storage the metadata of the file type we're uploading (in this case, JPEG) so that Firebase can correctly store them.
        let imageMetadata = StorageMetadata()
        imageMetadata.contentType = "image/jpeg"
        
        // We'll use putDataAsync to upload the file to Firebase storage, but it returns a value. We don't need this value, so we'll use an underscore to trash it.
        let _ = try await path.putDataAsync(imageData, metadata: imageMetadata)
        
        // Now that the file is uploaded, we can get the download link for the image:
        let url = try await path.downloadURL()
        
        // We'll return the entire string:
        return url.absoluteString
    }
    
    // Now we need a function to delete, or "complete", posts after the textbook seller has either changed their mind or sold the textbook. We'll need the id of the post to delete it first.
    func deletePost(id: String) async throws {
        try await db.collection("TextbookPosts").document(id).delete()
    }
}
