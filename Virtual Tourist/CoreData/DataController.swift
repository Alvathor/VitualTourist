//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 16/06/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        
        return persistentContainer.viewContext
    }
    
    let backgroundContext: NSManagedObjectContext!
    
    init(modelName: String) {
        
        persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContext() {
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
    }
    
    func load(completion: (() -> Void)? = nil) {
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            self.autoSaveViewContext(interval: 5)
            self.configureContext()
            completion?()
        }
    }
}

extension DataController {
    
    func autoSaveViewContext(interval: TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negativa autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            
            self.autoSaveViewContext(interval: interval)
        }
    }
}
