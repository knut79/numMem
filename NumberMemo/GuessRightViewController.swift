//
//  GuessRightViewController.swift
//  NumberMemo
//
//  Created by knut on 19/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GuessRightViewController: UIViewController{
    
    @IBOutlet weak var onlyMarkedLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var markedSwith: UISwitch!
    @IBOutlet weak var fromPickerView: UIPickerView!
    @IBOutlet weak var toPickerView: UIPickerView!
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var relationItems = [Relation]()
    
    func fetchRelations() {
        
        let fetchRequest = NSFetchRequest(entityName: "Relation")
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Relation] {
            relationItems = fetchResults
        }
        if(relationItems.count > 0)
        {
        toPickerView.selectRow(relationItems.count - 1, inComponent: 0, animated: true)
        toSelectedRow = relationItems.count - 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRelations()
        

        
        if(relationItems.count == 0)
        {
            startButton.alpha = 0.0
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    var fromSelectedRow = 0
    var toSelectedRow = 0
    func pickerView(pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int)
    {
        if(pickerView == fromPickerView)
        {
            fromSelectedRow = row
            if(fromSelectedRow > toSelectedRow)
            {
                toSelectedRow = fromSelectedRow
                toPickerView.selectRow(row, inComponent: 0, animated: true)
            }
        }
        else //toPickerView
        {
            toSelectedRow = row
            if(toSelectedRow < fromSelectedRow)
            {
                fromSelectedRow = toSelectedRow
                fromPickerView.selectRow(row, inComponent: 0, animated: true)
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return relationItems.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String
    {
        
        return relationItems[row].number
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showPlayGuessRight") {
            let svc = segue!.destinationViewController as! PlayGuessRightViewController;
            
            svc.maxCardIndex = toSelectedRow
            svc.minCardIndex = fromSelectedRow
            svc.onlyMarked = markedSwith.on
        }
    }
}
