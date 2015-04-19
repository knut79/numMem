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

    @NSManaged var number: String
    @NSManaged var other: String
    @NSManaged var verb: String
    @NSManaged var subject: String
    @NSManaged var marked: Boolean
    @NSManaged var avg:Float
    @NSManaged var timesanswered:Int16
    @NSManaged var timesfailed:Int16
    //@NSManaged var numberrelationsubject: String
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, number: String, verb: String, subject: String, otherrelation: String) -> Relation{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Relation", inManagedObjectContext: moc) as Relation
        newitem.number = number
        newitem.verb = verb
        newitem.subject = subject
        newitem.other = otherrelation
        newitem.marked = 0
        newitem.avg = 0.0
        newitem.timesanswered = 0
        newitem.timesfailed = 0
        
        return newitem
    }
    
}
