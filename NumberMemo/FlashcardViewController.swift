//
//  FlashcardViewController.swift
//  NumberMemo
//
//  Created by knut on 20/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlashcardViewController: UIViewController{
    
    

    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var randomizeSwith: UISwitch!
    @IBOutlet weak var fromPickerView: UIPickerView!
    @IBOutlet weak var toPickerView: UIPickerView!
    @IBAction func randomizeSwitchChanged(sender: UISwitch) {

    }
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var relationItems = [Relation]()
    
    func fetchRelations() {
        
        let fetchRequest = NSFetchRequest(entityName: "Relation")
        let sortDescriptor = NSSortDescriptor(key: "titlenumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Relation] {
            relationItems = fetchResults
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

            return relationItems[row].titlenumber
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "ToFlashCardPlay") {
            var svc = segue!.destinationViewController as PlayFlashCardsViewController;
            
            svc.maxCardIndex = toSelectedRow
            svc.minCardIndex = fromSelectedRow
            svc.randomize = randomizeSwith.on
            
        }
    }
}