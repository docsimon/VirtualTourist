//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by doc on 30/04/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataController: DataController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        dataController = DataController(dataModel: "Locations")
        dataController.loadDb { error in
            print(error)
        }
        // get the reference to the MapViewController in order to inject the dataController
        if let navigationController = window?.rootViewController as? UINavigationController,
           let mapViewController = navigationController.topViewController as? MapViewController{
            // Injecting the dataController into the first ViewController
            mapViewController.dataController = dataController
        }else{
            fatalError("Problem instantiating initial view controllers")
        }
        return true
    }
}

