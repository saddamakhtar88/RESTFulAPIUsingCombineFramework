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
    
    private var _defaultCachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    private var _defaultTimeoutInterval = 60.0 // in seconds
    
    private let _urlSession: URLSession
    private var _urlSessionTask: URLSessionTask?
    
    init(session: URLSession) {
        _urlSession = session
    }
    
    // MARK: - Public functions
    
    public func request(endpoint: HTTPEndpoint) throws -> AnyPublisher<Data?, Error> {
        let session = _urlSession
        do {
            let request = try urlRequest(from: endpoint)
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
    
    // MARK: - Private functions
    
    private func urlRequest(from endpoint: HTTPEndpoint) throws -> URLRequest {
        
        var queryItems = [URLQueryItem]()
        endpoint.queryParams.forEach { (key, value) in
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        guard var urlComps = URLComponents(string: endpoint.url.absoluteString) else {
            throw HTTPEndpointError.urlError("Cannot fetch URL components")
        }
        
        urlComps.queryItems = queryItems
        
        guard let url = urlComps.url else {
            throw HTTPEndpointError.urlError("Cannot fetch URL after queryItems are added")
        }
        
        var request = URLRequest(url: url,
                                 cachePolicy: endpoint.cachePolicy ?? _defaultCachePolicy,
                                 timeoutInterval: endpoint.timeoutInterval ?? _defaultTimeoutInterval)
        
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        endpoint.headers.forEach({ (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        })
        
        return request
    }
}
