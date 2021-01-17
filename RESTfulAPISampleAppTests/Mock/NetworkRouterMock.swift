//
//  MockNetworkRouter.swift
//  RESTfulAPISampleAppTests
//
//  Created by Saddam Akhtar on 1/12/21.
//

import Foundation
import Combine
@testable import RESTfulAPISampleApp

class NetworkRouterMock: NetworkRouter {
    
    var data: Data?
    var error: Error?
    
    private var currentValueSubject: CurrentValueSubject<Data?, Error>
    
    init(data: Data? = nil,
         error: Error? = nil) {
        self.data = data
        self.error = error
        
        currentValueSubject = CurrentValueSubject<Data?, Error>(data)
        
        if error != nil {
            currentValueSubject.send(completion: .failure(error!))
        }
    }
    
    func request(endpoint: HTTPEndpoint) throws -> AnyPublisher<Data?, Error> {
        currentValueSubject = CurrentValueSubject<Data?, Error>(data)
        if error != nil {
            currentValueSubject.send(completion: .failure(error!))
        }
        
        return currentValueSubject
            .eraseToAnyPublisher()
    }
}
