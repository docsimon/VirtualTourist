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
    func updateGallery(photo: Gallery)
    func updateGalleryFromDB(photo: [Photo])
    func cleanGallery()
    func updateTitle(title: String)
}


class PhotoGalleryViewModel {
    let dataController: DataController
    let coordinates: CLLocationCoordinate2D
    var pin: Pin!
    var currentPage = 1
    weak var delegate: PhotoGalleryDelegate?
    
    init(dataController: DataController, coordinates: CLLocationCoordinate2D) {
        self.dataController = dataController
        self.coordinates = coordinates
    }
    
    func getPhotoUrls(page: Int){
        pin = fetchPin(coordinates)
        // check if there are stored photos for the pin
        if let photos = fetchPhoto(pin), photos.count > 0 {
            delegate?.updateGalleryFromDB(photo: photos)
        } else {
            let client = Client()
            var urlComponents = URLComponents(string: Constants.Client.baseUrl)
            //urlComponents.host = Constants.Client.baseUrl
            var queryItemsArray = [URLQueryItem]()
            queryItemsArray.append(URLQueryItem(name: "api_key", value: Constants.Client.apiKey))
            queryItemsArray.append(URLQueryItem(name: "lon", value: String(coordinates.longitude)))
            queryItemsArray.append(URLQueryItem(name: "lat", value: String(coordinates.latitude)))
            queryItemsArray.append(URLQueryItem(name: "radius", value: "5"))
            queryItemsArray.append(URLQueryItem(name: "format", value: "json"))
            queryItemsArray.append(URLQueryItem(name: "method", value: "flickr.photos.search"))
            queryItemsArray.append(URLQueryItem(name: "extras", value: "url_m"))
            queryItemsArray.append(URLQueryItem(name: "safe_search", value: "1"))
            queryItemsArray.append(URLQueryItem(name: "page", value: String(page)))
            queryItemsArray.append(URLQueryItem(name: "per_page", value: "21"))
            queryItemsArray.append(URLQueryItem(name: "nojsoncallback", value: "?"))
            urlComponents?.queryItems = queryItemsArray
            
            guard let url = urlComponents?.url else {
                print("Error in url")
                return
            }
            
            client.fetchRemoteData(request: url, dataHandler: .dataListHandler, completion: { listData, errorData  in
                
                if let error = errorData {
                    //self.delegate?.displayError(errorData: error)
                    print("Error: ", error.errorTitle)
                    return
                }
                
                guard let listData = listData as? Flickr else {
                    print("error")
                    return
                }
                
                self.delegate?.updateGallery(photo: listData.photos)
            })
        }
    }
    
    func fetchImage(url: String, completion: @escaping (Data?) -> () ){
        let client = Client()
        guard let url = URL(string: url) else {
            print("Invalid url")
            return
        }
        client.fetchRemoteData(request: url, dataHandler: .dataHandler) { data, error in
            
            guard error == nil else {
                print("Error")
                return
            }
            
            guard let data = data as? Data else {
                print("Error")
                return
            }
            
            self.addPhoto(url: url.absoluteString, data: data)
            completion(data)
        }
    }
    
    func getLocationDescription(){
        
    }
    func lookUpCurrentLocation(){
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil {
                if let firstLocation = placemarks?[0] {
                    self.delegate?.updateTitle(title: firstLocation.locality ?? "Unknown location")
                }
            }
            else {
                self.delegate?.updateTitle(title: "Unknown location")
            }
        })
    }
    
    func fetchPin(_ coordinates: CLLocationCoordinate2D) -> Pin?{
        let longitude = coordinates.longitude
        let latitude = coordinates.latitude
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "longitude == %lf && latitude == %lf", longitude, latitude)
        fetchRequest.predicate = predicate
        if let result = try? dataController.context.fetch(fetchRequest){
            if result.count > 0 {
                return result[0]
            }
        }
        return nil
    }
    
    func fetchPhoto(_ pin: Pin) -> [Photo]?{
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        if let result = try? dataController.context.fetch(fetchRequest){
            return result
        }
        return nil
    }
    
    func addPhoto(url: String, data: Data){
        let photo = Photo(context: dataController.context)
        photo.payload = data
        photo.url = url
        photo.pin = pin
        dataController.saveDB(context: dataController.context)
    }
    func deletePhoto(photo: Photo){
        dataController.context.delete(photo)
    }
    
    func loadNewGallery(){
        // First remove all the photo for the pin
        if let photos = fetchPhoto(pin) {
            for photo in photos {
                deletePhoto(photo: photo)
            }
        }
        dataController.saveDB(context: dataController.context)
        delegate?.cleanGallery()
        currentPage =  (currentPage == 1) ? 2 : 1
        getPhotoUrls(page: currentPage)
    }
    
    func removePhotos(list: [IndexPath:String]){
       print("removed from db")
    }
}

