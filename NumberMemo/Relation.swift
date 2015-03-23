//
//  Relation.swift
//  NumberMemo
//
//  Created by knut on 16/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

class Relation: NSManagedObject {

    @NSManaged var titlenumber: String
    @NSManaged var numberrelation: String
    @NSManaged var numberrelationverb: String
    //@NSManaged var numberrelationsubject: String
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, thenumber: String, therelation: String) -> Relation{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Relation", inManagedObjectContext: moc) as Relation
        newitem.titlenumber = thenumber
        newitem.numberrelation = therelation
        //newitem.numberrelationsubject = ""
        newitem.numberrelationverb = ""
        
        return newitem
    }

}
