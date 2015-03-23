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

class PlayFlashCardsViewController: UIViewController{
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
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
    
    @IBOutlet var TapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Now that the view loaded, we have a frame for the view, which will be (0,0,screen width, screen height)
        // This is a good size for the table view as well, so let's use that
        // The only adjust we'll make is to move it down by 20 pixels, and reduce the size by 20 pixels
        // in order to account for the status bar
        
        // Store the full frame in a temporary variable
        var viewFrame = self.view.frame
        
        // Adjust it down by 20 points
        //viewFrame.origin.y += 20
        
        
        slideInFromRightTransition.delegate = self
        // Customize the animation's properties
        slideInFromRightTransition.type = kCATransitionPush
        slideInFromRightTransition.subtype = kCATransitionFromRight
        slideInFromRightTransition.duration = 1.0
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromRightTransition.fillMode = kCAFillModeRemoved
        
        
        slideInFromLeftTransition.delegate = self
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromLeft
        slideInFromLeftTransition.duration = 1.0
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved

        
        let aSelector : Selector = "flipCard:"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        let cSelector : Selector = "nextCard:"
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "lastCard:")
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
        
        
        
        
        let rect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width * 0.7, UIScreen.mainScreen().bounds.size.height * 0.7)
        cardView = UIView(frame: rect)
        cardView.backgroundColor = UIColor.lightGrayColor()
        cardView.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2, y: UIScreen.mainScreen().bounds.size.height/2)
        
        
        fetchRelations()
        
        labelFront = UILabel(frame: CGRectMake(0, 0, cardView.bounds.size.width, 60))
        labelFront.textAlignment = NSTextAlignment.Center
        labelFront.center = CGPoint(x: cardView.bounds.size.width/2,y: cardView.bounds.size.height/2)
        labelFront.text = cards[currentCard].front
        self.view.addSubview(labelFront)
        
        
        labelBack = UILabel(frame: CGRectMake(0, 0, cardView.bounds.size.width, 60))
        labelBack.textAlignment = NSTextAlignment.Center
        labelBack.center = CGPoint(x: cardView.bounds.size.width/2,y: cardView.bounds.size.height/2)
        labelBack.text = cards[currentCard].back
        labelBack.hidden = true
        self.view.addSubview(labelBack)
        
        cardView.addSubview(labelFront)
        view.addSubview(cardView)
    
        
        
    }
    
    func fetchRelations() {
        
        let fetchRequest = NSFetchRequest(entityName: "Relation")
        let sortDescriptor = NSSortDescriptor(key: "titlenumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Relation] {
            for(var i = minCardIndex; i <= maxCardIndex ; i++)
            {
                cards.append(Card(front: fetchResults[i].titlenumber, back: fetchResults[i].numberrelation))
            }
            
            if(randomize)
            {
                cards = shuffle(cards)
            }
            //relationItems = fetchResults
        }
    }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let count = countElements(list)
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
    
    var showingBack = false
    
    func flipCard(sender: AnyObject) {
        
        /*if(labelFront.text == cards[currentCard].front)
        {
            labelFront.text = cards[currentCard].back
        }
        else
        {
            labelFront.text = cards[currentCard].front
        }*/
        labelBack.hidden = false
        if (showingBack) {
            UIView.transitionFromView(labelBack, toView: labelFront, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = false
        } else {
            UIView.transitionFromView(labelFront, toView: labelBack, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            showingBack = true
        }
    }

    
    @IBAction func nextCard(sender: AnyObject) {
        
        
        if (showingBack) {
            UIView.transitionFromView(labelBack, toView: labelFront, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = false
            labelBack.hidden = true
        }
        // Add the animation to the View's layer
        self.cardView.layer.addAnimation(slideInFromRightTransition, forKey: "slideInFromRightTransition")
        
        
        self.currentCard++
        self.currentCard = self.currentCard % cards.count
        labelFront.text = cards[currentCard].front
        labelBack.text = cards[currentCard].back
    }
    
    @IBAction func lastCard(sender: AnyObject) {

        if (showingBack) {
            UIView.transitionFromView(labelBack, toView: labelFront, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = false
            labelBack.hidden = true
        }
        // Add the animation to the View's layer
        self.cardView.layer.addAnimation(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
        
        self.currentCard--
        self.currentCard = self.currentCard < 0 ? (cards.count - 1) : self.currentCard
        labelFront.text = cards[currentCard].front
        labelBack.text = cards[currentCard].back
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
