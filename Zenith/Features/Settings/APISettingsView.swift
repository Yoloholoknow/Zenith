//
//  APISettingsView.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import SwiftUI

struct APISettingsView: View {
    @StateObject private var networkManager = NetworkManager.shared
    @State private var apiKey = ""
    @State private var isSecureEntry = true
    @State private var showingSaveAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        Image(systemName: "key")
                            .font(.system(size: 50))
                            .foregroundColor(ThemeColors.primaryBlue)
                        
                        Text("LLM API Configuration")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        Text("Connect to an AI service to generate personalized daily tasks")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(ThemeColors.cardBackground)
                    .cornerRadius(12)
                    
                    // Connection Status
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: networkManager.isConnected ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundColor(networkManager.isConnected ? ThemeColors.successGreen : ThemeColors.warningOrange)
                                .font(.title3)
                            
                            Text("Connection Status")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(connectionStatusText)
                                .font(.subheadline)
                                .foregroundColor(networkManager.isConnected ? ThemeColors.successGreen : ThemeColors.textSecondary)
                            
                            Spacer()
                            
                            if networkManager.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Button("Test Connection") {
                                    networkManager.checkConnection()
                                }
                                .font(.caption)
                                .foregroundColor(ThemeColors.primaryBlue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(ThemeColors.primaryBlue, lineWidth: 1)
                                )
                                .disabled(!networkManager.hasValidAPIKey())
                            }
                        }
                    }
                    .dashboardCard()
                    
                    // API Key Configuration
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(ThemeColors.secondaryPurple)
                            
                            Text("API Key Configuration")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Google Gemini API Key")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            HStack {
                                Group {
                                    if isSecureEntry {
                                        SecureField("Enter your API key", text: $apiKey)
                                            .foregroundColor(ThemeColors.textPrimary)
                                    } else {
                                        TextField("Enter your API key", text: $apiKey)
                                            .foregroundColor(ThemeColors.textPrimary)
                                    }
                                }
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .background(ThemeColors.backgroundDark)
                                .cornerRadius(8)
                                
                                Button(action: {
                                    isSecureEntry.toggle()
                                }) {
                                    Image(systemName: isSecureEntry ? "eye" : "eye.slash")
                                        .foregroundColor(ThemeColors.textSecondary)
                                }
                            }
                            
                            Text("Your API key is stored securely on your device and only used to communicate with the AI service.")
                                .font(.caption)
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                        
                        HStack {
                            Button("Clear Key") {
                                apiKey = ""
                                networkManager.setAPIKey("")
                                alertMessage = "API key cleared successfully"
                                showingSaveAlert = true
                            }
                            .foregroundColor(.red)
                            .disabled(apiKey.isEmpty && !networkManager.hasValidAPIKey())
                            
                            Spacer()
                            
                            Button("Save Key") {
                                saveAPIKey()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(apiKey.isEmpty)
                        }
                    }
                    .dashboardCard()
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(ThemeColors.primaryBlue)
                            
                            Text("How to Get Your API Key")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            instructionStep(number: "1", text: "Visit ai.google.dev and create an account.")
                            instructionStep(number: "2", text: "Navigate to 'Get API Key' and create a new key.")
                            instructionStep(number: "3", text: "Copy the key and paste it above.")
                        }
                        
                        Text("Note: The free tier of the Gemini API may have rate limits and data usage policies. See the Gemini API documentation for details.")
                            .font(.caption)
                            .foregroundColor(ThemeColors.warningOrange)
                            .padding(.top, 8)
                    }
                    .dashboardCard()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("API Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentAPIKey()
            }
            .alert("API Key", isPresented: $showingSaveAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private var connectionStatusText: String {
        if networkManager.isLoading {
            return "Testing connection..."
        } else if networkManager.isConnected {
            return "Connected successfully"
        } else if !networkManager.hasValidAPIKey() {
            return "No API key configured"
        } else {
            return "Connection failed"
        }
    }
    
    private func instructionStep(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(ThemeColors.primaryBlue)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(ThemeColors.textPrimary)
            
            Spacer()
        }
    }
    
    private func loadCurrentAPIKey() {
        if networkManager.hasValidAPIKey() {
            apiKey = String(repeating: "•", count: 20) // Show masked version
        }
    }
    
    private func saveAPIKey() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKey.isEmpty else {
            alertMessage = "Please enter a valid API key"
            showingSaveAlert = true
            return
        }
        
        networkManager.setAPIKey(trimmedKey)
        alertMessage = "API key saved successfully"
        showingSaveAlert = true
        
        // Test connection after saving
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            networkManager.checkConnection()
        }
    }
}
