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
    func updateTitle(title: String)
}


class PhotoGalleryViewModel {
    let dataController: DataController
    let coordinates: CLLocationCoordinate2D
    weak var delegate: PhotoGalleryDelegate?
    
    init(dataController: DataController, coordinates: CLLocationCoordinate2D) {
        self.dataController = dataController
        self.coordinates = coordinates
    }
    
    func getPhotoUrls(){
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
}

