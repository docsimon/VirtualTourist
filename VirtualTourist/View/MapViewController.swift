//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by doc on 30/04/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    var dataController: DataController!
    var mapViewModel: MapViewModel?
    var selectedPin: MKAnnotationView?
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
    fileprivate func addPin(_ currentPin: MKPointAnnotation) {
        currentPin.title = "Photo Gallery"
        currentPin.subtitle = "tap to view"
        DispatchQueue.main.async {
            self.mapView.addAnnotation(currentPin)
        }
    }
    
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
        let currentPin = MKPointAnnotation()
        currentPin.coordinate = touchedAtCoordinate
        if recognizer.state == .ended {
            addPin(currentPin)
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
        if let pin = selectedPin {
            mapViewModel?.deletePin(pin: pin)
            editButton.isEnabled = false
        }
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
        editButton.isEnabled = true
        selectedPin = view
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        editButton.isEnabled = false
        selectedPin = nil
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "photoGallery", sender: nil)
        }
    }
}
// Navigation
extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? PhotoGalleryViewController {
            destVC.pinCoordinates = selectedPin?.annotation?.coordinate
            destVC.dataController = dataController
        }
    }
}
