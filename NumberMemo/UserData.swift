//
//  UserData.swift
//  NumberMemo
//
//  Created by knut on 22/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

@objc(UserData)
class UserData: NSManagedObject {
    
    @NSManaged var currentwholenumber: String
    @NSManaged var currentcorrectnumber: String
    @NSManaged var currentwrongnumber: String
    
   
    class func createInManagedObjectContext(moc: NSManagedObjectContext, wholenumber:String, rightnumber: String, wrongnumber: String) -> UserData{

        let newitem = NSEntityDescription.insertNewObjectForEntityForName("UserData", inManagedObjectContext: moc) as UserData
        newitem.currentcorrectnumber = rightnumber
        newitem.currentwrongnumber = wrongnumber
        newitem.currentwholenumber = wholenumber

        return newitem
    }
    
}