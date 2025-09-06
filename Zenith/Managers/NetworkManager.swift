//
//  NetworkManager.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Configuration
    private let baseURL = "https://api.openai.com/v1"
    private var apiKey: String {
        return UserDefaults.standard.string(forKey: "llm_api_key") ?? ""
    }
    
    @Published var isConnected = false
    @Published var isLoading = false
    @Published var lastError: NetworkError?
    
    private init() {
        checkConnection()
    }
    
    // MARK: - API Key Management
    
    func setAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "llm_api_key")
        checkConnection()
    }
    
    func hasValidAPIKey() -> Bool {
        return !apiKey.isEmpty
    }
    
    // MARK: - Connection Testing
    
    func checkConnection() {
        guard hasValidAPIKey() else {
            isConnected = false
            return
        }
        
        isLoading = true
        
        let url = URL(string: "\(baseURL)/models")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTaskPublisher(for: request)
            .map(\.response)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.isConnected = false
                        self?.lastError = NetworkError.connectionFailed(error.localizedDescription)
                        print("❌ API connection failed: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] response in
                    if let httpResponse = response as? HTTPURLResponse {
                        self?.isConnected = httpResponse.statusCode == 200
                        print(self?.isConnected == true ? "✅ API connection successful" : "❌ API returned error code: \(httpResponse.statusCode)")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Generic Request Method
    
    func makeRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        
        guard hasValidAPIKey() else {
            return Fail(error: NetworkError.noAPIKey)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: responseType, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return NetworkError.decodingFailed
                } else if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum NetworkError: Error, LocalizedError {
    case noAPIKey
    case invalidURL
    case invalidResponse
    case connectionFailed(String)
    case serverError(Int)
    case decodingFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key is required"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingFailed:
            return "Failed to decode response"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
