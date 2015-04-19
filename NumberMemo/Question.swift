//
//  Question.swift
//  NumberMemo
//
//  Created by knut on 19/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class Question
{
    var value: String
    var answers: [String]
    var marked: Boolean
    var nsManagedObject: Relation
    
    init(question:String, answers:[String], marked:Boolean, nsManagedObject: Relation){
        self.value = question
        self.answers = answers
        self.marked = marked
        self.nsManagedObject = nsManagedObject
    }
}