//
//  ImageSearchNetworkServiceTests.swift
//  RESTfulAPISampleAppTests
//
//  Created by Saddam Akhtar on 1/11/21.
//

import XCTest
@testable import RESTfulAPISampleApp

class ImageSearchNetworkServiceTests: XCTestCase {
    
    override func setUpWithError() throws {
        DI.register { () -> Environment in Development() }
    }

    override func tearDownWithError() throws {
        DI.reset()
    }

    func testGetImagesNetworkError() throws {
        // Scenario setup
        DI.register { () -> NetworkRouter in NetworkRouterMock(error: NetworkError.failed) }
        
        // Execution and assertion
        let expectation = XCTestExpectation(description: "network error")
        
        _ = ImageSearchNetworkService().getImages(for: "test-data").sink { completion in
            switch completion {
            case .failure(let error):
                XCTAssert(error is NetworkError, "Expected error of type NetworkError")
                expectation.fulfill()
            case .finished:
                XCTFail()
            }
        } receiveValue: { result in
            XCTFail("The request was supposed to fail but it is completed successfully")
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testGetImagesResponseDecodeError() throws {
        // Scenario setup
        let responseData = try! JSONEncoder().encode(ImageModel())
        DI.register { () -> NetworkRouter in NetworkRouterMock(data: responseData) }

        // Execution and assertion
        let expectation = XCTestExpectation(description: "decoding error")
        _ = ImageSearchNetworkService().getImages(for: "test-data").sink { completion in
            switch completion {
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case .finished:
                XCTFail()
            }
        } receiveValue: { result in
            XCTFail()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testGetImagesNoDataError() throws {
        // Scenario setup
        DI.register { () -> NetworkRouter in NetworkRouterMock(data: nil) }
        
        // Execution and assertion
        let expectation = XCTestExpectation(description: "network error")
        
        _ = ImageSearchNetworkService().getImages(for: "test-data").sink { completion in
            switch completion {
            case .failure(let error):
                XCTAssert(error is NetworkError, "Expected error of type NetworkError")
                expectation.fulfill()
            case .finished:
                XCTFail()
            }
        } receiveValue: { result in
            XCTFail("The request was supposed to fail but it is completed successfully")
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testGetImagesSuccess() throws {
        // Scenario setup
        let responseData = try! JSONEncoder().encode(ImageSearchResultModel())
        DI.register { () -> NetworkRouter in NetworkRouterMock(data: responseData) }

        // Execution and assertion
        let expectation = XCTestExpectation(description: "decoding error")
        _ = ImageSearchNetworkService().getImages(for: "test-data").sink { completion in
            switch completion {
            case .failure(_):
                XCTFail()
            case .finished:
                XCTFail()
            }
        } receiveValue: { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
