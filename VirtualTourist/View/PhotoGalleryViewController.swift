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
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var viewModel: PhotoGalleryViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coordinates = pin {
            viewModel = PhotoGalleryViewModel(dataController: dataController, coordinates: coordinates)
            viewModel?.delegate = self
            viewModel?.getPhotoUrls()
            viewModel?.lookUpCurrentLocation()
        }
        setFlowLayout()
    }
    private func setFlowLayout(){
        let space:CGFloat = 5
        let width = (view.frame.size.width - 25)/3
        let height = width
        
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}

extension PhotoGalleryViewController: PhotoGalleryDelegate {
    func updateGallery(photo: Gallery) {
        gallery = photo.photo
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.gallery?.count == 0 {
                self.locationTitle.text = "No photos available"
            }
        }
    }
    
    func updateTitle(title: String) {
        DispatchQueue.main.async {
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
        cell.activityIndicator.hidesWhenStopped = true
        cell.startActivity()
        self.viewModel?.fetchImage(url: gallery[indexPath.row].url_m) { data in
            
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                cell.stopActivity()
                cell.set(imageData: data)
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

