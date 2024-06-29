//
//  BackForAppService.swift
//  SyncCoreData
//
//  Created by Iury da Rocha Miguel on 28/06/24.
//

import Foundation

private struct NetworkResponse<T: Decodable>: Decodable {
    let results: [T]
}

protocol BackForAppServiceProtocol {
    func getAllRecords<T: Class>(ofType type: T.Type, updatedAfterDate: Date?) async throws -> [T]
}

final class BackForAppService: BackForAppServiceProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func getAllRecords<T: Class>(ofType type: T.Type, updatedAfterDate: Date?) async throws -> [T] {
        var parameters = [String: String]()
        if let updatedAfterDate {
            let dateString = DateFormatterHelper.formatToString(
                from: updatedAfterDate,
                format: "yyyy-MM-dd'T'HH:mm:ss.'999Z'"
            )
            let parameterString = """
            {"updatedAt":{"$gte":{"__type":"Date","iso":"\(dateString)"}}}
            """
            parameters = ["where": parameterString]
        }
        let response: NetworkResponse<T> = try await networkClient.get(urlPath: "classes/\(type.name)", parameters: parameters)
        return response.results
    }
}
