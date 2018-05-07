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

    var pin: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coordinates = pin {
            print(coordinates.coordinate.latitude)
        }
    }

}
