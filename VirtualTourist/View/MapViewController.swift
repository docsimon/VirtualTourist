//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by doc on 30/04/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit
import MapKit

enum MapStatus {
    case normal
    case edit
}

class MapViewController: UIViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    var mapStatus: MapStatus = .normal
    var dataController: DataController!
    var mapViewModel: MapViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapViewModel = MapViewModel(dataController: dataController)
        mapViewModel?.delegate = self
        mapViewModel?.loadPin()
        // add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.0 // in seconds
        //add gesture recognition
        mapView.addGestureRecognizer(longPress)
    }
    
    // func called when gesture recognizer detects a long press
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        resetStatus()
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
        let currentPin = MKPointAnnotation()
        currentPin.coordinate = touchedAtCoordinate
        if recognizer.state == .ended {
            mapView.addAnnotation(currentPin)
            updateDB(pin: currentPin)
        }
    }
    
    // this function is called when the user has finished to set a new location.
    // it saves the location to the db
    func updateDB(pin: MKPointAnnotation){
        mapViewModel?.savePin(coordinates: pin)
    }
    
    // delete the slected pin
    @IBAction func deletePin(_ sender: Any) {
        mapStatus = mapStatus == .normal ? .edit : .normal
        editButton.title = mapStatus == .normal ? "Edit" : "Done"
    }
    func resetStatus(){
        mapStatus = .normal
        editButton.title = "Edit"
    }
    
}
extension MapViewController: MapViewPinsDelegate {
    func updatePinsOnTheMap(pins: [MKPointAnnotation]) {
            self.mapView.addAnnotations(pins)
    }
    func removePinFromMap(pin: MKAnnotation){
        DispatchQueue.main.async {
            self.mapView.removeAnnotation(pin)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        switch mapStatus {
        case .normal:
            print()
        case .edit:
            // delete it form the DB
            mapViewModel?.deletePin(pin: view)
        }
    }
}
