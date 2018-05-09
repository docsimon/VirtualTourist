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
    
    @IBOutlet weak var deletePhotos: UIBarButtonItem!
    @IBOutlet weak var locationTitle: UILabel!
    var collectionSize = 0
    var gallery: [PhotoF]?
    var photoGallery = [Int:Photo]()
    var selectedCells = [IndexPath:String]()
    var pinCoordinates: CLLocationCoordinate2D?
    var dataController: DataController!
    var photoCache = [Int:Data]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var viewModel: PhotoGalleryViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        deletePhotos.isEnabled = false
        if let coordinates = pinCoordinates {
            viewModel = PhotoGalleryViewModel(dataController: dataController, coordinates: coordinates)
            viewModel?.delegate = self
            viewModel?.getPhotoUrls(page: 1)
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
    @IBAction func newGallery(_ sender: Any) {
        deletePhotos.isEnabled = false
        selectedCells.removeAll()
        photoCache.removeAll()
        viewModel?.loadNewGallery()
    }
    @IBAction func trashPhotos(_ sender: Any) {
        // remove from db the selected cells
        
        viewModel?.removePhotos(list: selectedCells)
        
        // remove from the collection view displayed
        collectionSize -= selectedCells.count
        collectionView.deleteItems(at: Array(selectedCells.keys))
        for index in selectedCells {
            photoGallery.removeValue(forKey: index.key.row)
            photoCache.removeValue(forKey: index.key.row)
        }
        selectedCells.removeAll()
        deletePhotos.isEnabled = false

    }
    
    deinit {
        print("PhotoGalleryViewController deallocated")
    }
}

extension PhotoGalleryViewController: PhotoGalleryDelegate {
    func updateGallery(photo: Gallery) {
        gallery = photo.photo
        DispatchQueue.main.async {
            if self.gallery?.count == 0 {
                self.locationTitle.text = "No photos available"
            }else {
                self.collectionSize = (self.gallery?.count)!
                self.collectionView.reloadData()
            }
        }
    }
    
    func updateGalleryFromDB(photo: [Photo]) {
        
        for (i, val) in photo.enumerated() {
            photoGallery[i] = val
        }
        DispatchQueue.main.async {
            self.collectionSize = self.photoGallery.count
            self.collectionView.reloadData()
        }
    }
    
    func updateTitle(title: String) {
        DispatchQueue.main.async {
            self.locationTitle.text = title
        }
    }
    
    func cleanGallery(){
        DispatchQueue.main.async {
            self.collectionSize = 0
            self.photoGallery.removeAll()
            self.photoCache.removeAll()
            self.gallery = nil
            self.collectionView.reloadData()
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
        return collectionSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if deletePhotos.isEnabled == false {
            cell.imageView.alpha = 1.0
        }
        
        cell.activityIndicator.hidesWhenStopped = true
        if  photoGallery.count > 0 {
            if let data = photoGallery[indexPath.row], let payload = data.payload {
                cell.set(imageData: payload)
                cell.url = data.url
            }
            print("photo from DB")
        }else {
            if let cache = photoCache[indexPath.row] {
                print("photo from cache")
                cell.set(imageData: cache)
            }else {
               print("photo from web")
                cell.resetCellImage()
                cell.stopActivity()
                cell.startActivity()
                cell.url = gallery![indexPath.row].url_m
                self.viewModel?.fetchImage(url: gallery![indexPath.row].url_m) { data in
                    
                    guard let data = data else {
                        return
                    }
                    self.photoCache[indexPath.row] = data
                    DispatchQueue.main.async {
                        cell.stopActivity()
                        cell.set(imageData: data)
                    }
                }
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        cell.setSelected()
        if let _ = selectedCells[indexPath] {
            selectedCells.removeValue(forKey: indexPath)
        }else {
            selectedCells[indexPath] = cell.url
        }
        if selectedCells.count > 0 {
            deletePhotos.isEnabled = true
        }else{
            deletePhotos.isEnabled = false
        }
    }
    
}

