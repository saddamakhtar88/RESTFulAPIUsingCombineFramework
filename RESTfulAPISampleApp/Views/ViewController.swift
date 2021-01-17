//
//  ViewController.swift
//  RESTfulAPISampleApp
//
//  Created by Saddam Akhtar on 1/11/21.
//

import UIKit
import DependencyRegistry
import Combine

class ViewController: UIViewController {

    @Inject() var imageSearchService: ImageSearchService
    
    var subscriptionToken: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscriptionToken = imageSearchService.getImages(for: "mango").sink { completion in
            switch completion {
            case .failure(let error):
                print(error)
            case .finished:
                print("Completed")
            }
        } receiveValue: { result in
            print("Total images in first page is \(result?.images.count ?? 0)")
        }
    }
}
