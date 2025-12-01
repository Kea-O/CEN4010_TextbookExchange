//
//  SignUpView.swift
//  CEN4010_TextbookApp
//
//  Created by Keagan O'Leary on 12/2/25.
//
import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) var authManager
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSigningUp = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                
                // Title
                VStack(spacing: 4) {
                    Text("Create Account")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 20)
                    
                    Text("Join Textbook Trader")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Input fields
                VStack(spacing: 20) {
                    
                    // Username
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Username")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    // Email
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Confirm Password
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Password")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal, 32)
                
                // Sign Up Button
                Button {
                    Task { await signUp() }
                } label: {
                    HStack {
                        if isSigningUp {
                            ProgressView()
                        } else {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .disabled(isSigningUp || !isFormValid)
                .animation(.easeInOut, value: isSigningUp)
                
                Spacer()
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSigningUp)
                }
            }
            .alert("Sign Up Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // VALIDATION
    private var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    // SIGN UP FUNCTION
    private func signUp() async {
        guard isFormValid else {
            errorMessage = "Please fill out all fields correctly. Password must be at least 6 characters."
            showErrorAlert = true
            return
        }
        
        isSigningUp = true
        defer { isSigningUp = false }
        
        do {
            try await authManager.signUp(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password,
                username: username.trimmingCharacters(in: .whitespaces)
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

#Preview {
    SignUpView()
        .environment(AuthManager())
}

