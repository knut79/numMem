//
//  SolveNumberViewController.swift
//  NumberMemo
//
//  Created by knut on 21/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//
import UIKit
import CoreData


class SolveNumberViewController: UIViewController {

    @IBOutlet weak var numDigitsLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var unregularNumberPicker: UIPickerView!
    @IBOutlet weak var generateNumberButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    let staticIrregularNumbers  = [("pi","3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"),
        ("e (Euler's Number)","2.7182818284590452353602874713527"),
        ("Golden Ratio","1.61803398874989484820"),
        ("Rubics cube combos","43252003274489856000"),
        ("Feigenbaum number","4. 669201609102990671853203820466201617258185577475768632745651 343004134330211314737138689744023948013817165984855189815134 408627142027932522312442988890890859944935463236713411532481 714219947455644365823793202009561058330575458617652222070385 410646749494284981453391726200568755665952339875603825637225"),
        ("Pythagoras' constant √2","1.41421356237309504880168872420969807856967187537694807317667973799"),
        ("Apéry's constant ζ(3)","1.2020569"),
        ("Euler–Mascheroni constant γ","0.57721"),
        ("Conway's constant λ","1.30357"),
        ("Khinchin's constant K","2.6854520010"),
        ("Glaisher-Kinkelin constant A","1.2824271291"),
        ("Reciprocal Fibonacci constant","3.35988566624317755317201130291892717")
        
    ]
    
    var staticstoreItems = [Staticstore]()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    
    func fetchUserData() {
        
        let fetchRequest = NSFetchRequest(entityName: "Staticstore")
        

        let sortDescriptor = NSSortDescriptor(key: "wholenumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        
        var error: NSError?
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Staticstore]
        {
            if(error != nil)
            {
                println("Error executing request for entity \(error?.description)")
            }
            
            println("length of fetchResults array \(fetchResults.count)")
            if( fetchResults.count > 0 )
            {
                numberLabel.text = fetchResults[0].wholenumber
                numDigitsLabel.text = "\(numberLabel.text!.utf16Count) digits"
            }
            staticstoreItems = fetchResults

        }


    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    @IBAction func generateNumberButtonPushed(sender: UIButton) {
        
        var numberString:String = ""
        var numDigits = 100
        for(var i = 0 ; i < 100 ; i++)
        {
            var num:Int = randomInt(0,max: 9)
            var str:String = String(num)
            numberString += str
        }
        numberLabel.text = numberString
        startButton.setTitle("Start", forState: .Normal)
        numDigitsLabel.text = "\(numDigits) digits"
        
        
        staticstoreItems[0].wholenumber = numberString
        staticstoreItems[0].correctnumber = ""
        staticstoreItems[0].wrongnumber = ""
        save()
    }
    
    @IBAction func startButtonPushed(sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        startButton.setTitle("Continue with last number", forState: .Normal)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchUserData()
        numberLabel.text = staticstoreItems[0].wholenumber
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int)
    {
        var val = staticIrregularNumbers[row].1
        startButton.setTitle("Start", forState: .Normal)
        numberLabel.text = staticIrregularNumbers[row].1
        numDigitsLabel.text = "\(numberLabel.text!.utf16Count - 1) digits"
        
       
        if(staticstoreItems.count == 0)
        {
            var newUserDataItem = Staticstore.createInManagedObjectContext(self.managedObjectContext!, wholenumber: numberLabel.text!, rightnumber: "" , wrongnumber: "")
        }
        else
        {
            staticstoreItems[0].wholenumber = numberLabel.text!
            staticstoreItems[0].correctnumber = ""
            staticstoreItems[0].wrongnumber = ""
        }
        
        
        save()

    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return staticIrregularNumbers.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String
    {
        
        return staticIrregularNumbers[row].0
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "ToFlashCardPlay") {
            var svc = segue!.destinationViewController as PlaySolveNumberViewController;
            
            svc.number = numberLabel.text
        }
    }
}
