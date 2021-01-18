//
//  HttpTaskRouter.swift
//  RESTfulAPISampleApp
//
//  Created by Saddam Akhtar on 1/11/21.
//

import Foundation
import Combine

// MARK: - NetworkRouter implementation

public class HTTPNetworkRouter: NetworkRouter {

    // MARK: - Private properties
    
    private let _urlSession: URLSession
    private var _urlSessionTask: URLSessionTask?
    
    init(session: URLSession) {
        _urlSession = session
    }
    
    // MARK: - Public functions
    
    public func request(endpoint: Endpoint) throws -> AnyPublisher<Data?, Error> {
        let session = _urlSession
        do {
            let request = try endpoint.urlRequest()
            return session
                .dataTaskPublisher(for: request)
                .tryMap() { element -> Data? in
                    guard let httpResponse = element.response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    
                    switch httpResponse.statusCode {
                    case 200...299: return element.data
                    case 401...500: throw NetworkError.authenticationError
                    case 501...599: throw NetworkError.badRequest
                    case 600: throw NetworkError.outdated
                    default: throw NetworkError.failed
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            throw URLError(.badURL)
        }
    }
}
