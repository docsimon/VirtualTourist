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
    
    @IBOutlet weak var locationTitle: UILabel!
    var gallery: [PhotoF]?
    var pin: CLLocationCoordinate2D?
    var dataController: DataController!
    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel: PhotoGalleryViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coordinates = pin {
            viewModel = PhotoGalleryViewModel(dataController: dataController, coordinates: coordinates)
            viewModel?.delegate = self
            viewModel?.getPhotoUrls()
            viewModel?.lookUpCurrentLocation()
        }
    }

}

extension PhotoGalleryViewController: PhotoGalleryDelegate {
    func updateGallery(photo: Gallery) {
        gallery = photo.photo
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func updateTitle(title: String) {
        DispatchQueue.main.async {
            self.locationTitle.textAlignment = .center
            self.locationTitle.text = title
        }
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
// MARK: Collection view delegate
extension PhotoGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell, let gallery = gallery else {
            return UICollectionViewCell()
        }

        self.viewModel?.fetchImage(url: gallery[indexPath.row].url_m) { data in
            
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                cell.set(imageData: data)
            }
            
        }
        return cell
    }
}

