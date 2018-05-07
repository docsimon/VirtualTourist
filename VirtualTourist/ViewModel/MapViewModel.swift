//
//  MapViewModel.swift
//  VirtualTourist
//
//  Created by doc on 06/05/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation
import MapKit
import CoreData

// This class has the following functions
/*
 - save to DB, via CoreData, the Pin dropped onthe map by the user
 - populate the map, from the DB, with the pins when starting the app
 */

protocol MapViewPinsDelegate: class {
    func updatePinsOnTheMap(pins: [MKPointAnnotation])
    func removePinFromMap(pin: MKAnnotation)
}

class MapViewModel {
    let dataController: DataController
    weak var delegate: MapViewPinsDelegate?
    
    init(dataController: DataController) {
        self.dataController = dataController
    }
    
    func savePin(coordinates: MKPointAnnotation){
        let pin = Pin(context: dataController.context)
        pin.latitude = coordinates.coordinate.latitude as Double
        pin.longitude = coordinates.coordinate.longitude as Double
        
        dataController.saveDB(context: dataController.context)
    }
    
    func loadPin(){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let result = try dataController.context.fetch(fetchRequest)
            // extract coordinates and call the delegate method
            if result.count > 0 {
                print(result[0].latitude)
                let coordinates: [MKPointAnnotation] = result.map {pin in
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate.latitude = CLLocationDegrees(pin.latitude)
                    annotation.coordinate.longitude = CLLocationDegrees(pin.longitude)
                    annotation.title = "Photo Gallery"
                    annotation.subtitle = "tap to view"
                    return annotation
                }
                delegate?.updatePinsOnTheMap(pins: coordinates)
            }
        }catch {
            print("Error fetching DB")
        }
    }
    
    func deletePin(pin: MKAnnotationView){
        print("deleting...")
        guard let longitude = pin.annotation?.coordinate.longitude,
            let latitude = pin.annotation?.coordinate.latitude else {
                print("Invalid coordinates")
                return
        }
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "longitude == %lf && latitude == %lf", longitude, latitude)
        fetchRequest.predicate = predicate
        if let result = try? dataController.context.fetch(fetchRequest){
            if result.count > 0 {
                dataController.context.delete(result[0])
                dataController.saveDB(context: dataController.context)
                delegate?.removePinFromMap(pin: pin.annotation!)
            }else{
                print("Empty result")
            }
        }else {
            print("Pin has not been deleted")
        }
    }
}
