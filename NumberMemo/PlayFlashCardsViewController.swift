//
//  PlayFlashCardsViewController.swift
//  NumberMemo
//
//  Created by knut on 22/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import iAd
class PlayFlashCardsViewController: UIViewController, ADBannerViewDelegate{
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var cards:Array<Card> = Array<Card>()
    var currentCard = 0
    var labelFront: UILabel!
    var labelBack: UILabel!
    var cardView: UIView!
    let slideInFromRightTransition = CATransition()
    let slideInFromLeftTransition = CATransition()
    var maxCardIndex:Int = 0
    var minCardIndex:Int = 0
    var randomize: Bool = false
    var onlyMarked: Bool = false
    var autoreveal: Bool = false
    let makedString:String = " ❌"
    @IBOutlet var TapGesture: UITapGestureRecognizer!
    
    var labelTimer: UILabel!
    var timerCount = 0
    var timerRunning = false
    var timer = NSTimer()
    
    var bannerView:ADBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.canDisplayBannerAds = true
        bannerView = ADBannerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        self.view.addSubview(bannerView!)
        self.bannerView?.delegate = self
        self.bannerView?.hidden = false
        
        slideInFromRightTransition.delegate = self
        // Customize the animation's properties
        slideInFromRightTransition.type = kCATransitionPush
        slideInFromRightTransition.subtype = kCATransitionFromRight
        slideInFromRightTransition.duration = 0.5
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromRightTransition.fillMode = kCAFillModeRemoved
        
        
        slideInFromLeftTransition.delegate = self
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromLeft
        slideInFromLeftTransition.duration = 0.5
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved

        
        let aSelector : Selector = #selector(PlayFlashCardsViewController.flipCard(_:))
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PlayFlashCardsViewController.nextCard(_:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PlayFlashCardsViewController.lastCard(_:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PlayFlashCardsViewController.markCard(_:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(downSwipe)
        
        
        
        let rect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width * 0.7, UIScreen.mainScreen().bounds.size.height * 0.5)
        cardView = UIView(frame: rect)
        cardView.backgroundColor = UIColor.lightGrayColor()
        cardView.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2, y: UIScreen.mainScreen().bounds.size.height/2)
        
        
        fetchRelations()
        
        
        
        
        labelFront = UILabel(frame: CGRectMake(0, 0, cardView.bounds.size.width, 60))
        labelFront.textAlignment = NSTextAlignment.Center
        labelFront.font = UIFont.boldSystemFontOfSize(20)
        labelFront.center = CGPoint(x: cardView.bounds.size.width/2,y: cardView.bounds.size.height/2)
        labelFront.text = cards[currentCard].front
        self.view.addSubview(labelFront)
        
        
        labelBack = UILabel(frame: CGRectMake(0, 0, cardView.bounds.size.width, cardView.bounds.size.height))
        labelBack.textAlignment = NSTextAlignment.Center
        labelBack.numberOfLines = 6
        labelBack.center = CGPoint(x: cardView.bounds.size.width/2,y: cardView.bounds.size.height/2)
        labelBack.text = cards[currentCard].back
        labelBack.hidden = true
        self.view.addSubview(labelBack)
        
        cardView.addSubview(labelFront)
        view.addSubview(cardView)
        
        labelTimer = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 40))
        labelTimer.textAlignment = NSTextAlignment.Center
        labelTimer.font = UIFont.boldSystemFontOfSize(20)
        labelTimer.numberOfLines = 2
        labelTimer.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2,y: UIScreen.mainScreen().bounds.size.height * 0.15 )
        self.view.addSubview(labelTimer)
        
        startTimer()

    }
    
    func fetchRelations() {
        
        let fetchRequest = NSFetchRequest(entityName: "Relation")
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let addCardClosure:(Relation) -> () = {
            let fontText = $0.number +  ($0.marked == true ? self.makedString : "")
            self.cards.append(Card(front: fontText ,
                back: $0.subject + "\n" + $0.verb + "\n" + $0.other,
                marked: $0.marked,
                nsManagedObject: $0))
        }
        

        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Relation] {
            
            for i in minCardIndex ... maxCardIndex
            {
                if(onlyMarked)
                {
                    if(fetchResults[i].marked == true)
                    {
                        addCardClosure(fetchResults[i])
                    }
                }
                else
                {
                    addCardClosure(fetchResults[i])
                }
            }
            if(cards.count == 0)
            {
                let noMarkedNumbersPrompt = UIAlertController(title: "No marked numbers",
                    message: "Showing non marked numbers",
                    preferredStyle: .Alert)
                
                noMarkedNumbersPrompt.addAction(UIAlertAction(title: "OK",
                    style: .Default,
                    handler: { (action) -> Void in
                        return
                }))
                
                self.presentViewController(noMarkedNumbersPrompt,
                    animated: true,
                    completion: nil)
                
                for i in minCardIndex ... maxCardIndex
                {
                        addCardClosure(fetchResults[i])
                }
            }
            
            
            
            if(randomize)
            {
                cards = shuffle(cards)
            }

        }
    }
    
    func save() {
        do{
            try managedObjectContext!.save()
        } catch {
            print(error)
        }
    }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(list: C) -> C
    {
        var listMutable = list
        let ecount = listMutable.count
        for i in 0..<(ecount - 1) {
            let j = Int(arc4random_uniform(UInt32(ecount - i))) + i
            if j != i {
                swap(&listMutable[i], &listMutable[j])
            }
        }
        return listMutable
    }
    
    func startTimer()
    {
        
        if(!timerRunning)
        {
            labelTimer.textColor = UIColor.blackColor()
            labelTimer.font = UIFont.boldSystemFontOfSize(20)
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayFlashCardsViewController.timerCounting), userInfo: nil, repeats: true)
            timerRunning = true
        }
            
        timerCount = 0
        labelTimer.text = "\(self.timerCount)"
        
    }
    
    func pauseTimer()
    {
        timer.invalidate()
        timerRunning = false
    }
    
    func timerCounting()
    {
        self.timerCount += 1
        labelTimer.text = "\(self.timerCount)"
        
        if(autoreveal)
        {
            if(timerCount > 3)
            {
                timerCount = 0
                nextCard(nil)
            }
            if(timerCount > 2)
            {
                flipCard(nil)
            }

        }
        
        if(timerCount >= 10)
        {
            labelTimer.textColor = UIColor.redColor()
            if(timerCount >= 15)
            {
                labelTimer.font = UIFont.boldSystemFontOfSize(14)
                labelTimer.text = "More than 15 sec to memorize relation.\n Swipe down to mark"
                pauseTimer()
            }
        }
        else if(self.timerCount >= 5)
        {
            labelTimer.textColor = UIColor.orangeColor()
        }
        else
        {
            labelTimer.textColor = UIColor.blackColor()
        }
        
    }

    var showingBack = false
    
    func flipCard(sender: AnyObject?) {
        
        labelBack.hidden = false
        if (showingBack) {
            UIView.transitionFromView(labelBack, toView: labelFront, duration: 0.35, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = false
        } else {
            UIView.transitionFromView(labelFront, toView: labelBack, duration: 0.35, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            showingBack = true
        }
        if(!autoreveal)
        {
            pauseTimer()
        }
    }

    @IBAction func nextCard(sender: AnyObject?) {
        
        
        if (showingBack) {
            UIView.transitionFromView(labelBack, toView: labelFront, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = false
            labelBack.hidden = true
        }
        // Add the animation to the View's layer
        self.cardView.layer.addAnimation(slideInFromRightTransition, forKey: "slideInFromRightTransition")
        
        
        self.currentCard += 1
        self.currentCard = self.currentCard % cards.count
        labelFront.text = cards[currentCard].front
        labelBack.text = cards[currentCard].back
        
        startTimer()
    }
    
    @IBAction func lastCard(sender: AnyObject) {

        if (showingBack) {
            UIView.transitionFromView(labelBack, toView: labelFront, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = false
            labelBack.hidden = true
        }
        // Add the animation to the View's layer
        self.cardView.layer.addAnimation(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
        
        self.currentCard -= 1
        self.currentCard = self.currentCard < 0 ? (cards.count - 1) : self.currentCard
        labelFront.text = cards[currentCard].front
        labelBack.text = cards[currentCard].back
        
        startTimer()
    }
    
    func markCard(sender: AnyObject)
    {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.cardView.center = CGPointMake(self.cardView.center.x, self.cardView.center.y + 20)
            }, completion: { (value: Bool) in
                let relationItem = self.cards[self.currentCard].nsManagedObject
                if(self.cards[self.currentCard].marked == true)
                {
                    self.cards[self.currentCard].front = self.cards[self.currentCard].front.stringByReplacingOccurrencesOfString(self.makedString, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    self.cards[self.currentCard].marked = false
                    //unmark in db
                    relationItem.marked = false
                }
                else
                {
                    (self.cards[self.currentCard] as Card).front += self.makedString
                    self.cards[self.currentCard].marked = true
                    //mark i db
                    relationItem.marked = true
                    self.pauseTimer()
                }
                self.save()
                
                self.labelFront.text = self.cards[self.currentCard].front
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.cardView.center = CGPointMake(self.cardView.center.x, self.cardView.center.y - 20)
                })
        })
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
