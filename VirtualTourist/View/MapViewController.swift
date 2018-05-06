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

    @IBOutlet weak var mapView: MKMapView!
    let locationManager =  CLLocationManager()
    //var currentPin = MKPointAnnotation()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        // add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.0 // in seconds
        //add gesture recognition
        mapView.addGestureRecognizer(longPress)
    }
    
    // func called when gesture recognizer detects a long press
    
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates

        let currentPin = MKPointAnnotation()
        currentPin.coordinate = touchedAtCoordinate
        currentPin.title = currentPin.coordinate.latitude.description + " " + currentPin.coordinate.longitude.description
//        let geoDecoder = CLGeocoder()
//        geoDecoder.reverseGeocodeLocation(CLLocation(latitude: currentPin.coordinate.latitude, longitude: currentPin.coordinate.longitude), completionHandler: { placeMark, error in
//            if error == nil {
//                if let locations = placeMark {
//                    currentPin.title = locations[0].location.debugDescription ?? "Unknown location"
//                    print(locations[0].location.debugDescription)
//                }
//            }else {
//                currentPin.title = "Unknown"
//            }
//        })
        mapView.addAnnotation(currentPin)
        if recognizer.state == .ended {
            updateDB(pin: currentPin)
        }
    }
    
    // this function is called when the user has finished to set a new location.
    // it saves the location to the db
    func updateDB(pin: MKPointAnnotation){
        //print("updating db with: ", pin.title as! String, pin.coordinate)
        
    }
}

// conforming to MKMapView delegate
extension MapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        let reuseId = "pin"
//        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
//        if pinView == nil {
//            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            pinView!.canShowCallout = true
//            pinView!.pinTintColor = .red
//            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//        else {
//            pinView!.annotation = annotation
//        }
//
//        return pinView
//    }
//
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if control == view.rightCalloutAccessoryView {
//            let app = UIApplication.shared
//            if let subtitle = view.annotation?.subtitle, let toOpen = subtitle, let url = URL(string: toOpen) {
//                app.open(url, options: [:], completionHandler: nil)
//            }
//        }
//    }
}

extension MapViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("cippa")
//        let newPin = MKPointAnnotation()
//        let location = locations.last! as CLLocation
//
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//
//        //set region on the map
//        mapView.setRegion(region, animated: true)
//
//        newPin.coordinate = location.coordinate
//        mapView.addAnnotation(newPin)
//
//    }
}

