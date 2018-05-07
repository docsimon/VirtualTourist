//
//  PhotoGalleryViewModel.swift
//  VirtualTourist
//
//  Created by doc on 07/05/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation
import MapKit
import CoreData

protocol PhotoGalleryDelegate: class {
    func updateGallery(photo: [Photo])
    func updateTitle(title: String)
}


class PhotoGalleryViewModel {
    let dataController: DataController
    let coordinates: MKPointAnnotation
    weak var delegate: PhotoGalleryDelegate?
    
    init(dataController: DataController, coordinates: MKPointAnnotation) {
        self.dataController = dataController
        self.coordinates = coordinates
    }
    
}
