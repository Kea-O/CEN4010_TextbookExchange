//
//  LoginView.swift
//  CEN4010_TextbookApp
//
//  Created by Matthew on 12/1/25.
//
import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) var authManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggingIn = false
    @State private var showErrorAlert = false
    @State private var showSignUp = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 32) {
            
            // App Title
            Text("Textbook Trader")
                .font(.system(size: 34, weight: .bold))
                .padding(.top, 40)
            
            // Input Card
            VStack(spacing: 20) {
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
            }
            .padding(.horizontal, 32)
            
            // Login Button
            Button {
                Task { await login() }
            } label: {
                HStack {
                    if isLoggingIn {
                        ProgressView()
                    } else {
                        Text("Login")
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
            .disabled(isLoggingIn || email.isEmpty || password.isEmpty)
            .animation(.easeInOut, value: isLoggingIn)
            
            // Sign Up
            Button {
                showSignUp = true
            } label: {
                Text("Create a new account")
                    .font(.callout)
                    .foregroundStyle(.blue)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environment(authManager)
        }
        .alert("Login Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func login() async {
        isLoggingIn = true
        defer { isLoggingIn = false }
        
        do {
            try await authManager.signIn(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}
