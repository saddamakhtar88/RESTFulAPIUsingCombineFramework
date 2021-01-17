//
//  ImageSearchNetworkService.swift
//  RESTfulAPISampleApp
//
//  Created by Saddam Akhtar on 1/11/21.
//

import Foundation
import DependencyRegistry
import Combine

// MARK:- ImageSearchService network implementation

struct ImageSearchNetworkService: ImageSearchService {
    
    private var _networkRouter: NetworkRouter {
        DI.resolve(scope: Scope.unique)
    }
    
    func getImages(for searchKeyword: String) -> AnyPublisher<ImageSearchResultModel?, Error> {
        let networkRouter = _networkRouter
        let endpoint = ImageSearchEndpoint(sharedMetadata: EndpointSharedMetadata(),
                                           searchKeyword: searchKeyword)
        return try! networkRouter.request(endpoint: endpoint)
            .tryMap({ responseData -> Data in
                guard responseData != nil else {
                    throw NetworkError.noData
                }
                return responseData!
            })
            .decode(type: ImageSearchResultModel?.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// MARK:- Endpoints

private struct ImageSearchEndpoint: HTTPEndpoint {
    
    let sharedMetadata: EndpointSharedMetadata
    let searchKeyword: String
    
    var url: URL {
        // Configure the url with the required route
        sharedMetadata.baseUrl
    }
    var method: HTTPMethod { .get }
    
    var queryParams: [String: String] {
        let items = ["q": searchKeyword]
        return sharedMetadata.queryParams.merging(items) { (_, new) in new }
    }
    
    var headers: [String : String] { sharedMetadata.headers }
    var timeoutInterval: TimeInterval? { sharedMetadata.timeoutInterval }
    var cachePolicy: URLRequest.CachePolicy? { sharedMetadata.cachePolicy }
    
    var body: Data? { nil }
}
