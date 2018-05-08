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
    var collectionSize: Int?
    var gallery: [PhotoF]?
    var photoGallery: [Photo]?
    var pinCoordinates: CLLocationCoordinate2D?
    var dataController: DataController!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var viewModel: PhotoGalleryViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let coordinates = pinCoordinates {
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
            if self.gallery?.count == 0 {
                self.locationTitle.text = "No photos available"
            }else {
                self.collectionSize = self.gallery?.count
                self.collectionView.reloadData()
            }
        }
    }
    
    func updateGalleryFromDB(photo: [Photo]) {
        photoGallery = photo
        DispatchQueue.main.async {
            self.collectionSize = self.photoGallery?.count
            self.collectionView.reloadData()
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
        
        return collectionSize ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let photoGallery = photoGallery, let data = photoGallery[indexPath.row].payload  {
            cell.set(imageData: data)
        }else {
            cell.activityIndicator.hidesWhenStopped = true
            cell.startActivity()
            self.viewModel?.fetchImage(url: gallery![indexPath.row].url_m) { data in

                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    cell.stopActivity()
                    cell.set(imageData: data)
                }
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

