//
//  Staticstore.swift
//  NumberMemo
//
//  Created by knut on 22/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData


class Staticstore: NSManagedObject {
    
    @NSManaged var wholenumber: String
    @NSManaged var correctnumber: String
    @NSManaged var wrongnumber: String
    @NSManaged var beststrike:Int16
    
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, wholenumber:String, rightnumber: String, wrongnumber: String) -> Staticstore{
        
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Staticstore", inManagedObjectContext: moc) as! Staticstore
        newitem.correctnumber = rightnumber
        newitem.wrongnumber = wrongnumber
        newitem.wholenumber = wholenumber
        newitem.beststrike = 0
        
        return newitem
    }
    
}
