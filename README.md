# RESTful APIs using Combine Framework

Sample app for how to interact with Restful APIs using Combine Framework

This is not being developed as a Swift package because the idea of this sample is to have network layer raw implementation part of your individual project for finer control. Copy the relevant folders/files in your project and customize it (if required) as per your need.

### Approach:
- Reactive (Using Combine.Framework)
- Type safety
- Protocol oriented
- Dependency Injection
- Unit testing
- Without a third party dependency to have full control over the implementation

### Code snippets to help understand the sample app

#### Network router protocol [(Folder: Supporting -> Network)](https://github.com/saddamakhtar88/RESTFulAPIUsingCombineFramework/tree/master/RESTfulAPISampleApp/Supporting/Network)
The return type is 'AnyPublisher' from Combine framework
```swift
protocol NetworkRouter {
    func request(endpoint: Endpoint) throws -> AnyPublisher<Data?, Error>
}

protocol Endpoint {
    func urlRequest() throws -> URLRequest
}
```

#### HTTP Endpoint type [(Folder: Supporting -> Network)](https://github.com/saddamakhtar88/RESTFulAPIUsingCombineFramework/tree/master/RESTfulAPISampleApp/Supporting/Network)
It is used to define HTTP endpoints
```swift
protocol HTTPEndpoint: Endpoint {
    var url: URL { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryParams: [String: String] { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval? { get }
    var cachePolicy: URLRequest.CachePolicy? { get }
}
```

A concrete implementation [(HTTPNetworkRouter)](https://github.com/saddamakhtar88/RESTFulAPIUsingCombineFramework/blob/master/RESTfulAPISampleApp/Supporting/Network/HTTPNetworkRouter.swift) of the protocol for handling HTTP requests is already in place
```swift
public class HTTPNetworkRouter: NetworkRouter {...}
```

#### A sample RESTful endpoint wrapped in a service [(Folder: Data -> Service -> NetworkDataProvider)](https://github.com/saddamakhtar88/RESTFulAPIUsingCombineFramework/tree/master/RESTfulAPISampleApp/Data/Service/NetworkDataProvider)
It is internally using an injected NetworkRouter instance
```swift
struct ImageSearchNetworkService: ImageSearchService {
    
    // Computed property returning a new NetworkRouter instance everytime invoked
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
```

If you would have noticed, this service is further implemented over ImageSearchService protocol. The reason of this is to abstract the implementation. There could be a requirement in future to fetch data from a local database or somewhere else. With a protocol in place, such a change could be easily managed.

#### Finally consuming the endpoint to fetch data in [ViewController.swift](https://github.com/saddamakhtar88/RESTFulAPIUsingCombineFramework/blob/master/RESTfulAPISampleApp/Views/ViewController.swift)
```swift
@Inject() var imageSearchService: ImageSearchService

let subscriptionToken = imageSearchService.getImages(for: "garden").sink { completion in
            switch completion {
            case .failure(let error):
                print(error)
            case .finished:
                print("Completed")
            }
        } receiveValue: { result in
            print("Total images in first page is \(result?.images.count ?? 0)")
        }
```

#### Dependency setup in [AppDelegate](https://github.com/saddamakhtar88/RESTFulAPIUsingCombineFramework/blob/master/RESTfulAPISampleApp/AppDelegate.swift)
Dependencies are injected during app startup
```swift
DI.register { () -> NetworkRouter in HTTPNetworkRouter(session: URLSession.shared) }
DI.register { () -> ImageSearchService in ImageSearchNetworkService() }
```

### Note
I have used [DependecyRegistry](https://github.com/saddamakhtar88/DependencyRegistry) Swift package for managing the dependencies. This is developed by myself. You may use one of your own.

