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



    @IBOutlet weak var parentNumverWebView: UIView!
    @IBOutlet weak var numberWebViewOverlay: UIView!
    @IBOutlet weak var numDigitsLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var unregularNumberPicker: UIPickerView!
    @IBOutlet weak var generateNumberButton: UIButton!
    @IBOutlet weak var numberLabel: UIWebView!
    var numberString: String = ""
    var numberHighlightLabel:UILabel!
    var numberOfHiglightedNumbers: Int = 2
    var currentHighlightNumberIndex = 0
    var overlayView:UIView!
    let staticIrregularNumbers  = [("pi","3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"),
        ("e (Euler's Number)","2.7182818284590452353602874713527"),
        ("Golden Ratio","1.61803398874989484820"),
        ("Rubics cube combos","43252003274489856000"),
        ("Feigenbaum number","4.669201609102990671853203820466201617258185577475768632745651343004134330211314737138689744023948013817165984855189815134408627142027932522312442988890890859944935463236713411532481 714219947455644365823793202009561058330575458617652222070385 410646749494284981453391726200568755665952339875603825637225"),
        ("Pythagoras' constant √2","1.41421356237309504880168872420969807856967187537694807317667973799"),
        ("Apéry's constant ζ(3)","1.2020569"),
        ("Euler–Mascheroni constant γ","0.57721"),
        ("Conway's constant λ","1.30357"),
        ("Khinchin's constant K","2.6854520010"),
        ("Glaisher-Kinkelin constant A","1.2824271291"),
        ("Reciprocal Fibonacci constant","3.35988566624317755317201130291892717")
        
    ]
    let slideInFromRightTransition = CATransition()
    let slideInFromLeftTransition = CATransition()
    
    var staticstoreItems = [Staticstore]()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        slideInFromRightTransition.delegate = self
        // Customize the animation's properties
        slideInFromRightTransition.type = kCATransitionPush
        slideInFromRightTransition.subtype = kCATransitionFromRight
        slideInFromRightTransition.duration = 0.25
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromRightTransition.fillMode = kCAFillModeRemoved
        
        slideInFromLeftTransition.delegate = self
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromLeft
        slideInFromLeftTransition.duration = 0.25
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        
        // Do view setup here.
        startButton.setTitle("Set a number !", forState: .Normal)
        startButton.enabled = false
        
        fetchUserData()
        if(staticstoreItems.count == 0)
        {
            Staticstore.createInManagedObjectContext(self.managedObjectContext!, wholenumber: "", rightnumber: "" , wrongnumber: "")
            fetchUserData()
        }
        numberString = staticstoreItems[0].wholenumber
        setTextForNumberLabel(numberString)
        
        if(numberString.utf16.count > 0)
        {
            startButton.setTitle("Continue with last number", forState: .Normal)
            startButton.enabled = true
        }
        
        numberHighlightLabel = UILabel(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width, 44 ))
        numberHighlightLabel.text = ""
        numberHighlightLabel.textAlignment =  NSTextAlignment.Center
        numberHighlightLabel.font = UIFont.boldSystemFontOfSize(20)
        overlayView = UIView(frame: CGRectMake(0,0, UIScreen.mainScreen().bounds.size.width , UIScreen.mainScreen().bounds.size.height/3))
        overlayView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.height/3)
        overlayView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.9)
        
        overlayView.layer.cornerRadius = 2
        overlayView.layer.borderWidth = 2
        overlayView.layer.borderColor = UIColor.blueColor().CGColor

        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SolveNumberViewController.increaseNumberOfNumbers(_:)))
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        overlayView.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SolveNumberViewController.decreaseNumberOfNumbers(_:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        overlayView.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SolveNumberViewController.nextNumbers(_:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        overlayView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SolveNumberViewController.lastNumbers(_:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        overlayView.addGestureRecognizer(rightSwipe)
        
        overlayView.addSubview(numberHighlightLabel)
        numberHighlightLabel.center = CGPointMake(overlayView.bounds.size.width/2, overlayView.bounds.size.height/2)
        
        
        self.view.addSubview(overlayView)
        
        
        let aSelector : Selector = #selector(SolveNumberViewController.tapOnNumberPanel(_:))
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        numberWebViewOverlay.userInteractionEnabled = true
        numberWebViewOverlay.addGestureRecognizer(tapGesture)
        
        self.overlayView.frame.size.height = self.numberWebViewOverlay.frame.height
        self.overlayView.frame.size.width = self.numberWebViewOverlay.frame.size.width
        self.overlayView.center = self.parentNumverWebView.center
        self.overlayView.alpha = 0.0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(overlayView)
    }
    
    func fetchUserData() {
        let fetchRequest = NSFetchRequest(entityName: "Staticstore")
        let sortDescriptor = NSSortDescriptor(key: "wholenumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let fetchResults = (try?managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Staticstore]
        {
            
            print("length of fetchResults array \(fetchResults.count)")
            if( fetchResults.count > 0 )
            {
                numberString = fetchResults[0].wholenumber
                setTextForNumberLabel(numberString)
                numDigitsLabel.text = "\(numberString.utf16.count) digits"
            }
             staticstoreItems = fetchResults
        }
    }
    
    func save() {
        do{
            try managedObjectContext!.save()
        } catch {
            print(error)
        }
    }
    
    func setTextForNumberLabel(text:String)
    {
        numberLabel.loadHTMLString("<html><div style=\"word-wrap: break-word;\">" + text + "</div></html>", baseURL: nil)
    }
    
    func setTextWithHighlightForNumberLabel(number:String,startindex:String.Index, endindex:String.Index)
    {
        let prefixBold = "<span style=\"background-color: #ffff42\">"
        let suffixBold = "</span>"
        //let indexStart: String.Index = advance(number.startIndex, startindex)
        //let indexEnd: String.Index = advance(number.startIndex, endindex)
        //let range = Range<String.Index>( start: startindex, end: endindex)
        let range:Range<String.Index> = startindex ..< endindex
        
        let numbersBeforePrefix = number.substringToIndex(startindex)
        let numbersToHighlight = prefixBold + number.substringWithRange(range) + suffixBold
        let numbersAfterSuffix = number.substringFromIndex(endindex)
        
        numberLabel.loadHTMLString("<html><div style=\"word-wrap: break-word;\">" + numbersBeforePrefix + numbersToHighlight + numbersAfterSuffix + "</div></html>", baseURL: nil)
    }
    
    @IBAction func generateNumberButtonPushed(sender: UIButton) {
        
        numberString = ""
        let numDigits = 100
        for _ in 0  ..< 100
        {
            let num:Int = randomInt(0,max: 9)
            let str:String = String(num)
            numberString += str
        }
        
        setTextForNumberLabel(numberString)
        
        startButton.setTitle("Start", forState: .Normal)
        startButton.enabled = true
        startButton.alpha = 1.0
        numDigitsLabel.text = "\(numDigits) digits"

        staticstoreItems[0].wholenumber = numberString
        staticstoreItems[0].correctnumber = ""
        staticstoreItems[0].wrongnumber = ""
        save()
    }
    
    @IBAction func startButtonPushed(sender: UIButton) {
    }
 
    var firstTimeForHighlight = true
    func tapOnNumberPanel(sender: AnyObject) {
        
        if(!startButton.enabled)
        {
            return
        }
        if(overlayView.alpha <= 0.1)
        {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                
                if(self.firstTimeForHighlight)
                {
                    self.firstTimeForHighlight = false
                    //self.numberHighlightLabel.font = UIFont.systemFontOfSize(14)
                    self.numberHighlightLabel.text = "◀️swipe..⬆️..⬇️..swipe▶️"
                    
                }
                
                self.overlayView.frame.size.height = UIScreen.mainScreen().bounds.size.height/3
                self.overlayView.frame.size.width = UIScreen.mainScreen().bounds.size.width
                self.overlayView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.height/3)
                self.overlayView.alpha = 1.0
            })

        }
        else
        {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                
                self.overlayView.frame.size.height = self.numberWebViewOverlay.frame.height
                self.overlayView.frame.size.width = self.numberWebViewOverlay.frame.size.width
                self.overlayView.center = self.parentNumverWebView.center
                self.overlayView.alpha = 0.0
            })
            
        }
    }
    
    @IBAction func nextNumbers(sender: AnyObject) {
        currentHighlightNumberIndex += numberOfHiglightedNumbers
        

        numberHighlightLabel.layer.addAnimation(slideInFromRightTransition, forKey: "slideInFromRightTransition")
        setHighlightNumberLabel()
    }
    
    @IBAction func lastNumbers(sender: AnyObject) {
        currentHighlightNumberIndex -= numberOfHiglightedNumbers
        numberHighlightLabel.layer.addAnimation(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
        setHighlightNumberLabel()
    }
    
    @IBAction func increaseNumberOfNumbers(sender: AnyObject) {
        numberOfHiglightedNumbers += 1
        if(numberOfHiglightedNumbers > 10)
        {
            numberOfHiglightedNumbers = 10
        }

        setHighlightNumberLabel()
    }
    
    @IBAction func decreaseNumberOfNumbers(sender: AnyObject) {
        numberOfHiglightedNumbers -= 1
        if(numberOfHiglightedNumbers < 0)
        {
            numberOfHiglightedNumbers = 0
        }
        setHighlightNumberLabel()
    }
    
    func setHighlightNumberLabel()
    {
        let numbersValue = numberString
        
        if(numberOfHiglightedNumbers > numbersValue.utf16.count)
        {
            print("numberOfHiglightedNumbers \(numberOfHiglightedNumbers)")
            print("numbersValue.utf16Count \(numbersValue.utf16.count)")
            numberOfHiglightedNumbers = numbersValue.utf16.count
        }
        var end = false
        if((currentHighlightNumberIndex + numberOfHiglightedNumbers) >= numbersValue.utf16.count)
        {
            //currentHighlightNumberIndex = count(numbersValue.utf16)  - numberOfHiglightedNumbers
            end = true
        }
        if(currentHighlightNumberIndex < 0)
        {
            currentHighlightNumberIndex = 0
        }
        
        print("value 1 \(numbersValue.characters.count) value2\(currentHighlightNumberIndex)")
        if currentHighlightNumberIndex < numbersValue.characters.count
        {
            let indexStart: String.Index = numbersValue.startIndex.advancedBy(currentHighlightNumberIndex)
            let indexEnd: String.Index = end ? numbersValue.startIndex.advancedBy(numbersValue.utf16.count) : numbersValue.startIndex.advancedBy(currentHighlightNumberIndex + numberOfHiglightedNumbers)
            //let range = Range<String.Index>( start: indexStart, end: indexEnd)
            let range:Range<String.Index> = indexStart ..< indexEnd
            let currentNumbersToHighlight = numbersValue.substringWithRange(range)
            

            numberHighlightLabel.text = currentNumbersToHighlight

            
            //highlight in webview
            setTextWithHighlightForNumberLabel(numberString, startindex:indexStart, endindex:indexEnd)
        }
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
        startButton.setTitle("Start", forState: .Normal)
        numberString = staticIrregularNumbers[row].1
        numDigitsLabel.text = "\(numberString.utf16.count - 1) digits"
        
       
        if(staticstoreItems.count == 0)
        {
            Staticstore.createInManagedObjectContext(self.managedObjectContext!, wholenumber: numberString, rightnumber: "" , wrongnumber: "")
        }
        else
        {
            staticstoreItems[0].wholenumber = numberString
            staticstoreItems[0].correctnumber = ""
            staticstoreItems[0].wrongnumber = ""
        }
        
        
        save()
        
        if(numberString.utf16.count > 0)
        {
            startButton.enabled = true
        }
        setTextForNumberLabel(numberString)

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
            let svc = segue!.destinationViewController as! PlaySolveNumberViewController;
            
            svc.number = numberString
        }
    }
}
