//
//  SampleDataService.swift
//  RESTfulAPISampleApp
//
//  Created by Saddam Akhtar on 1/11/21.
//

import Foundation
import Combine

protocol ImageSearchService {
    func getImages(for searchKeyword: String) -> AnyPublisher<ImageSearchResultModel?, Error>
}
