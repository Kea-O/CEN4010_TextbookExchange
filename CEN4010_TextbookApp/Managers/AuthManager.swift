//
//  AuthManager.swift
//  CEN4010_TextbookApp
//
//  Created by Matthew on 12/2/25.
//

import Foundation
// Import Firebase Auth
import FirebaseAuth
// Import Firebase Firestore
import FirebaseFirestore

// Make class observable
@Observable
@MainActor
class AuthManager {
    // Connect to the Firebase Firestore database:
    private let db = Firestore.firestore()
    
    // A property to store the logged in user. User is an object provided by FirebaseAuth framework
    var firebaseUser: FirebaseAuth.User?
    
    // App user data from Firestore
    var appUser: AppUser?
    
    // Error message for authentication
    var errorMessage: String?
    
    // Check if user is authenticated
    var isAuthenticated: Bool {
        firebaseUser != nil && appUser != nil
    }
    
    // Fetch AppUser from Firestore
    func fetchAppUser(uid: String) async {
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if doc.exists {
                let data = doc.data() ?? [:]
                guard let name = data["name"] as? String,
                      let email = data["email"] as? String else {
                    errorMessage = "Invalid user data in Firestore"
                    return
                }
                appUser = AppUser(id: uid, name: name, email: email)
            } else {
                errorMessage = "User data not found in Firestore"
            }
        } catch {
            errorMessage = "Failed to fetch user data: \(error.localizedDescription)"
            print("Error fetching app user: \(error)")
        }
    }
    
    // Fetch AppUser by ID (for fetching sellers, etc.)
    func fetchUserById(userId: String) async throws -> AppUser? {
        let doc = try await db.collection("users").document(userId).getDocument()
        guard doc.exists else { return nil }
        let data = doc.data() ?? [:]
        guard let name = data["name"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        return AppUser(id: userId, name: name, email: email)
    }

    // Documentation for the function used; this is a Firebase-given function for signing up/creating a user  https://firebase.google.com/docs/auth/ios/start#sign_up_new_users
    func signUp(email: String, password: String, username: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update on main thread since `user` is an observable property
            self.firebaseUser = authResult.user
            
            // Create a dictionary with this data and then save it to Firebase Firestore so we can fetch their username later:
            let newUser = AppUser(
                id: authResult.user.uid,
                name: username,
                email: email
            )
            
            // Send the newUser to be stored in Firestore databases. They'll also be in the authentication, but this way we can assign usernames to them too. Use .document().setData() so that we can use the uid we have from the authResult.
            try db.collection("users").document(authResult.user.uid).setData(from: newUser)
            
            // Update appUser
            self.appUser = newUser
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    // Documentation for the function used; this is a Firebase-given function for logging in a user and authenticating that they exist https://firebase.google.com/docs/auth/ios/start#sign_in_existing_users
    func signIn(email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // Update on main thread
            self.firebaseUser = authResult.user
            
            // Fetch user data from Firestore
            await fetchAppUser(uid: authResult.user.uid)
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            firebaseUser = nil
            appUser = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("Error signing out: \(error)")
        }
    }
}
