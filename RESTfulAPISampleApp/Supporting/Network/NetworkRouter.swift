//
//  NetworkRouter.swift
//  RESTfulAPISampleApp
//
//  Created by Saddam Akhtar on 1/11/21.
//

import Foundation
import Combine

public protocol NetworkRouter {
    func request(endpoint: Endpoint) throws -> AnyPublisher<Data?, Error>
}

public protocol Endpoint {
    func urlRequest() throws -> URLRequest
}
