//
//  HTTPClient.swift
//  Networking
//
//  Created by Carlos Rodriguez Asensio on 22/10/25.
//

import Foundation

public protocol HTTPClientProtocol {
    func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response
}

public final class HTTPClient: HTTPClientProtocol {
    
    // MARK: Private Properties
    
    private let session: URLSession
    private let builder: RequestBuilderProtocol

    // MARK: Initializer

    public init(session: URLSession = .shared,
                builder: RequestBuilderProtocol = RequestBuilder()) {
        self.session = session
        self.builder = builder
    }

    // MARK: Public Functions

    public func execute<T>(_ endpoint: T) async throws -> T.Response where T : Endpoint {
        let request = try builder.buildRequest(from: endpoint)
        
        #if DEBUG
        NetworkLogger.log(request: request)
        #endif
        
        let (data, response) = try await session.data(for: request)
        
        #if DEBUG
        NetworkLogger.log(response: response, data: data)
        #endif
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.unknown(NSError(domain: "Invalid response", code: 0))
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw HTTPError.requestFailed(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.Response.self, from: data)
        } catch {
            #if DEBUG
            NetworkLogger.log(error: error)
            #endif
            throw HTTPError.decodingFailed(error)
        }
    }
}
