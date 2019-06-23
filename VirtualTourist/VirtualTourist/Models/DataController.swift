//
//  DataController.swift
//  VirtualTourist
//
//  Created by Bushra AlSunaidi on 6/21/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    static let shared = DataController()
    
    // MARK: - Core Data stack
    let persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    
    var viewContext: NSManagedObjectContext { return persistentContainer.viewContext }
    
    func load() {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
    
}
