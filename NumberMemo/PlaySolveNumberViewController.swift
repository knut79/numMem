//
//  PlaySolveNumberViewController.swift
//  NumberMemo
//
//  Created by knut on 22/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import iAd
import AVFoundation

class PlaySolveNumberViewController: UIViewController, ADBannerViewDelegate{

    @IBOutlet weak var correctNumbersLabel: UILabel!
    @IBOutlet weak var wrongNumbersLabel: UILabel!
    
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var commaButton: UIButton!
    @IBOutlet weak var zeroButton: UIButton!
    var labelForAnimation : UILabel!
    var number: String!
    var charNumberInNumber:Int = 0
    var lastNumberCorrect = false
    
    var staticstoreItems = [Staticstore]()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var audioPlayer = AVAudioPlayer()
    var correctSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("correct", ofType: "wav")!)
    var failedSounds = [NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("wrong1", ofType: "wav")!),NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("wrong2", ofType: "mp3")!)]
    var gameoverSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("timeup", ofType: "mp3")!)
    var winningSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("finish", ofType: "mp3")!)
    
    var bannerView:ADBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.canDisplayBannerAds = true
        bannerView = ADBannerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        self.view.addSubview(bannerView!)
        self.bannerView?.delegate = self
        self.bannerView?.hidden = false
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        correctNumbersLabel.text = ""
        wrongNumbersLabel.text = ""
        
        fetchUserData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //labelForAnimation = UILabel(frame: CGRectMake(0, 0, zeroButton!.bounds.size.width, zeroButton!.bounds.size.height))
        //labelForAnimation.hidden = false
        labelForAnimation = UILabel(frame: CGRectMake(0, 0, 60, 40))
        labelForAnimation.textAlignment = NSTextAlignment.Center
        labelForAnimation.text = " "
        labelForAnimation.alpha = 0.0
        
        self.view.addSubview(labelForAnimation)
    }
    
    func fetchUserData() {
        
        let fetchRequest = NSFetchRequest(entityName: "Staticstore")
        
        
        let sortDescriptor = NSSortDescriptor(key: "wholenumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Staticstore]
        {
            print("length of fetchResults array \(fetchResults.count)")
            if( fetchResults.count > 0 )
            {
                correctNumbersLabel.text = fetchResults[0].correctnumber
                wrongNumbersLabel.text = fetchResults[0].wrongnumber
                if( correctNumbersLabel.text!.utf16.count > 0)
                {
                    charNumberInNumber = correctNumbersLabel.text!.utf16.count
                }
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
    

    
    var jumpOutOfCheck = false
    func checkStringAndSetValue(number:String,senderButton:UIButton) -> Void{
        
        if jumpOutOfCheck{
            return
        }
        let checkValue = rightNumber(number)

        labelForAnimation.center = senderButton.center
        labelForAnimation.alpha = 1.0
        labelForAnimation.text = number
        
        //if last value was right and this value is wrong add a spacing to separate the wrong numbers
        if(checkValue.1)
        {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOfURL: self.correctSound)
            } catch let error1 as NSError {
                print(error1)
            }
            UIView.animateWithDuration(0.5, animations: {
                self.labelForAnimation.center = self.correctNumbersLabel!.center
                senderButton.backgroundColor = UIColor.greenColor()
                //self.correctNumbersLabel.backgroundColor = UIColor.greenColor()
                }, completion: {(Bool) in
                    
                    self.lastNumberCorrect = true
                    self.correctNumbersLabel.text! += checkValue.0
                    if(checkValue.0 == ".")
                    {
                        self.commaButton.enabled = false
                        self.commaButton.alpha = 0.5
                    }
                    self.labelForAnimation.alpha = 0.0
                    UIView.animateWithDuration(0.5, animations: {
                        senderButton.backgroundColor = UIColor.blackColor()
                        //self.correctNumbersLabel.backgroundColor = UIColor.lightGrayColor()
                        self.checkEndGame()
                    })
                    
            })
            
            
        }
        else
        {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOfURL: self.failedSounds[0])
            } catch let error1 as NSError {
                print(error1)
            }
            UIView.animateWithDuration(0.5, animations: {
                self.labelForAnimation.center = self.wrongNumbersLabel!.center
                senderButton.backgroundColor = UIColor.redColor()
                //self.wrongNumbersLabel.backgroundColor = UIColor.redColor()
                }, completion: {(Bool) in

                    if(self.lastNumberCorrect)
                    {
                        self.wrongNumbersLabel.text! += " "
                    }
                    self.lastNumberCorrect = false
                    self.wrongNumbersLabel.text! += number
                    
                    self.labelForAnimation.alpha = 0.0
                    
                    UIView.animateWithDuration(0.5, animations: {
                        senderButton.backgroundColor = UIColor.blackColor()
                        //self.wrongNumbersLabel.backgroundColor = UIColor.lightGrayColor()
                        self.checkEndGame()
                        
                        })
                    
            })

        }
    }
    
    func checkEndGame(_: Void)
    {
        staticstoreItems[0].correctnumber = self.correctNumbersLabel.text!
        staticstoreItems[0].wrongnumber = self.wrongNumbersLabel.text!
        save()
        
        let errorCount = 20
        if(wrongNumbersLabel.text!.utf16.count >= errorCount)
        {

            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: self.gameoverSound)
            } catch let error1 as NSError {
                print(error1)
                
            }
            wrongNumbersLabel.backgroundColor = UIColor.redColor()
            correctNumbersLabel.backgroundColor = UIColor.redColor()
            correctNumbersLabel.text = "More than \(errorCount) wrong digits. Try another number."
            //return jumpOutOfCheck = true
        }
        
        if(correctNumbersLabel.text!.utf16.count >= number.utf16.count)
        {
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: self.winningSound)
            } catch let error1 as NSError {
                print(error1)
                
            }
            correctNumbersLabel.backgroundColor = UIColor.greenColor()
            wrongNumbersLabel.backgroundColor = UIColor.greenColor()
            wrongNumbersLabel.text = "Super 👍 \(number.utf16.count) right digits"
            //return jumpOutOfCheck = true
        }
        self.audioPlayer.prepareToPlay()
        self.audioPlayer.play()
    }
    
    func checkIntAndSetValue(number:Int,senderButton:UIButton) -> Void{
        checkStringAndSetValue(String(number),senderButton: senderButton)
    }
    
    func rightNumber(oneNumber: String) -> (String,Bool){
        
        let indexStart: String.Index = number.startIndex.advancedBy(charNumberInNumber)
        let indexEnd: String.Index = number.startIndex.advancedBy(charNumberInNumber+1)
        let range = Range<String.Index>( start: indexStart, end: indexEnd)
        let currentChar = number.substringWithRange(range)
        
        if(currentChar == oneNumber)
        {
            charNumberInNumber++
        }
        return (currentChar,currentChar == oneNumber)
    }
    
    @IBAction func zeroButtonPushed(sender: UIButton) {
        checkIntAndSetValue(0,senderButton: sender)
    }
    
    @IBAction func commaButtonPushed(sender: UIButton) {
        checkStringAndSetValue(".",senderButton: sender)
    }
    
    @IBAction func oneButtonPushed(sender: UIButton) {
        checkIntAndSetValue(1,senderButton: sender)
    }
 
    @IBAction func twoButtonPushed(sender: UIButton) {
        checkIntAndSetValue(2,senderButton: sender)
    }
    
    @IBAction func threeButtonPushed(sender: UIButton) {
        checkIntAndSetValue(3,senderButton: sender)
    }
    
    @IBAction func fourButtonPushed(sender: UIButton) {
        checkIntAndSetValue(4,senderButton: sender)
    }
    
    @IBAction func fiveButtonPushed(sender: UIButton) {
        checkIntAndSetValue(5,senderButton: sender)
    }
    
    @IBAction func sixButtonPushed(sender: UIButton) {
        checkIntAndSetValue(6,senderButton: sender)
    }
    
    @IBAction func sevenButtonPushed(sender: UIButton) {
        checkIntAndSetValue(7,senderButton: sender)
    }
    
    @IBAction func eightButtonPushed(sender: UIButton) {
        checkIntAndSetValue(8,senderButton: sender)
    }
    
    @IBAction func nineButtonPushed(sender: UIButton) {
        checkIntAndSetValue(9,senderButton: sender)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func bannerViewDidLoadAd(banner: ADBannerView!) {
        self.bannerView?.hidden = false
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return willLeave
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        self.bannerView?.hidden = true
    }
    

}