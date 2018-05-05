//
//  DataController.swift
//  VirtualTourist
//
//  Created by doc on 05/05/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation
import CoreData

// This class has the following function:
// - create an instance of the NSPersistentContainer
// - provide easy access to the ManagedObjectContext
// - load the DB
// - provide any usefull method that simplify the data layer management

class DataController {
    
    let persistentContainer: NSPersistentContainer?
    
    init(dataModel: String) {
        persistentContainer = NSPersistentContainer(name: dataModel)
    }
    
    func loadDb() {
        persistentContainer?.loadPersistentStores(completionHandler: {description, error in
            
            guard error == nil else {
                fatalError((error?.localizedDescription) ?? "Cannot load DB")
            }
            
        } )
    }
    
    func saveDB(context: NSManagedObjectContext){
        if context.hasChanges {
            do {
                try context.save()
            }catch {
                print("Can't save context")
            }
        }
    }
    
}

