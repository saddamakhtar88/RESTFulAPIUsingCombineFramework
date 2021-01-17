//
//  NetworkRouter.swift
//  RESTfulAPISampleApp
//
//  Created by Saddam Akhtar on 1/11/21.
//

import Foundation
import Combine

protocol NetworkRouter {
    func request(endpoint: HTTPEndpoint) throws -> AnyPublisher<Data?, Error>
}
