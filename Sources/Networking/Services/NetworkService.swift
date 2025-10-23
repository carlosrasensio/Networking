//
//  NetworkService.swift
//  Networking
//
//  Created by Carlos Rodriguez Asensio on 23/10/25.
//

import Foundation

public protocol NetworkServiceProtocol {
    func request<T: Endpoint>(_ endpoint: T) async throws -> T.Response
}

public final class NetworkService: NetworkServiceProtocol {
    private let client: HTTPClientProtocol
    
    public init(client: HTTPClientProtocol = HTTPClient()) {
        self.client = client
    }
    
    public func request<T>(_ endpoint: T) async throws -> T.Response where T : Endpoint {
        try await client.execute(endpoint)
    }
}

