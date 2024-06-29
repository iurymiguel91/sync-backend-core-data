//
//  NetworkClient.swift
//  SyncCoreData
//
//  Created by Iury da Rocha Miguel on 28/06/24.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case networkError
    case corruptedData
}

protocol NetworkClientProtocol {
    func get<T: Decodable>(urlPath: String, parameters: [String: String]) async throws -> T
}

final class NetworkClient: NetworkClientProtocol {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let baseURL = "https://parseapi.back4app.com/parse/"
    private let baseHeaders = [
        "X-Parse-Application-Id": "rVqzDm1yeWsztX4RNVGeDTAR4MbTIzUIBibbYmWL",
        "X-Parse-REST-API-Key": "dISp72IBdo5oH1EwKyMbn9hVa6lzU5OtZbdh0Dq8"
    ]

    init(
        urlSession: URLSession = URLSession(configuration: .default),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = DateFormatterHelper.formatToDate(from: dateString) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
            }
            return date
        }
    }

    func get<T: Decodable>(urlPath: String, parameters: [String: String]) async throws -> T {
        let urlRequest = try makeURLRequest(urlPath: urlPath, httpMethod: "GET", parameters: parameters)
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.networkError
        }
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.corruptedData
        }
    }

    private func makeURLRequest(urlPath: String, httpMethod: String, parameters: [String: String]) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(urlPath)") else {
            throw NetworkError.badURL
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        urlRequest.allHTTPHeaderFields = parameters.merging(baseHeaders) { $1 }
        return urlRequest
    }
}
