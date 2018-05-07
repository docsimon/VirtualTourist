//
//  PhotoGalleryViewController.swift
//  VirtualTourist
//
//  Created by doc on 07/05/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit
import MapKit

class PhotoGalleryViewController: UIViewController {

    var pin: CLLocationCoordinate2D?
    var dataController: DataController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coordinates = pin {
            let viewModel = PhotoGalleryViewModel(dataController: dataController, coordinates: coordinates)
            viewModel.delegate = self
            viewModel.getPhotoUrls()
        }
    }

}

extension PhotoGalleryViewController: PhotoGalleryDelegate {
    func updateGallery(photo: Gallery) {
        for pic in photo.photo {
            print(pic.url_m)
        }
    }
    
    func updateTitle(title: String) {
        
    }
    
    
}

// MARK: Error Delegate
extension PhotoGalleryViewController: ErrorControllerProtocol {
    func dismissActivityControl() {
        
    }
    
    func presentError(alertController: UIAlertController) {
        present(alertController, animated: true)
    }
    
    func fetchData() {
        
    }
    
}
