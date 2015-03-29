//
//  Card.swift
//  NumberMemo
//
//  Created by knut on 21/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation


class Card
{
    var front: String
    let back: String
    var marked: Boolean
    var nsManagedObject: Relation
    
    init(front:String, back:String, marked:Boolean, nsManagedObject: Relation){
        self.front = front
        self.back = back
        self.marked = marked
        self.nsManagedObject = nsManagedObject
    }
}