//
//  DataController.swift
//  VirtualTourist
//
//  Created by Yoyo Chan on 2021-07-10.
//

import Foundation
import CoreData

class DataController{
    
    let persistenseContainer:NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        
        return persistenseContainer.viewContext
    }
    
    init(name: String) {
        persistenseContainer = NSPersistentContainer(name: name)
    }
    func load(completionHandler:(()-> Void)? = nil){
        persistenseContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSave()
            completionHandler?()
        }
    }
    
    func autoSave(interval: TimeInterval = 25){
        guard interval > 0 else {
            print("Cannot have negative save time")
            return
        }
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSave(interval: interval)
        }
    }
    
}
