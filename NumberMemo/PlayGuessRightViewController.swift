//
//  PlayGuessRightViewController.swift
//  NumberMemo
//
//  Created by knut on 19/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PlayGuessRightViewController: UIViewController{
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var questions:Array<Question> = Array<Question>()
    var currentQuestion = 0
    
    var questionLabel: UILabel!
    var answerButtons:[UIButton] = []
    //var labelBack: UILabel!
    //var cardView: UIView!
    let slideInFromRightTransition = CATransition()
    let slideInFromLeftTransition = CATransition()
    var maxCardIndex:Int = 0
    var minCardIndex:Int = 0
    
    var onlyMarked: Bool = false
    var autoreveal = true
    let makedString:String = " ❌"
    @IBOutlet var TapGesture: UITapGestureRecognizer!
    
    var labelTimer: UILabel!
    var timerCount = 0
    var timerRunning = false
    var timer = NSTimer()
    
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
        
        
        fetchRelations()
        
        questionLabel = UILabel(frame: CGRectMake(0, 0, 100, 60))
        questionLabel.textAlignment = NSTextAlignment.Center
        questionLabel.font = UIFont.boldSystemFontOfSize(20)
        questionLabel.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2,y: UIScreen.mainScreen().bounds.size.height * 0.30)
        questionLabel.text = questions[currentQuestion].value
        self.view.addSubview(questionLabel)
        
        
        self.populateAnswerButtons()
        
        self.setAnswersOnButtons()

        
        labelTimer = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 40))
        labelTimer.textAlignment = NSTextAlignment.Center
        labelTimer.font = UIFont.boldSystemFontOfSize(20)
        labelTimer.numberOfLines = 2
        labelTimer.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2,y: UIScreen.mainScreen().bounds.size.height * 0.15 )
        self.view.addSubview(labelTimer)
        
        startTimer()
        
    }
    
    func populateAnswerButtons()
    {
        var rightAnswerIndex = randomNumber(range: 0...4)
        for(var i = 0 ; i < 5 ; i++)
        {
            var tempButton = UIButton(frame: CGRectMake(0, 0 , 200, 40))
            var y = CGFloat(45 * i) + questionLabel.frame.maxY + questionLabel.frame.height
            
            tempButton.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, y)
            
            let selector: Selector = "giveAnswer:"
            tempButton.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
            tempButton.backgroundColor = UIColor.blackColor()
            tempButton.titleLabel?.textColor = UIColor.whiteColor()
            
            answerButtons.append(tempButton)
            self.view.addSubview(tempButton)
        }
    }
    
    func fetchRelations() {
        
        let fetchRequest = NSFetchRequest(entityName: "Relation")
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var addQuestionClosure:(Relation) -> () = {
            var questionText = $0.number +  ($0.marked == 1 ? self.makedString : "")
            var answers:[String] = []
            if($0.verb != "")
            {
                answers.append($0.verb)
            }
            if($0.subject != "")
            {
                answers.append($0.subject)
            }
            if($0.other != "")
            {
                answers.append($0.other)
            }
            if(answers.count > 0)
            {
                self.questions.append(Question(question: questionText, answers:answers, marked:$0.marked, nsManagedObject: $0))
            }
        }
        
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Relation] {
            
            for(var i = minCardIndex; i <= maxCardIndex ; i++)
            {
                if(onlyMarked)
                {
                    if(fetchResults[i].marked == 1)
                    {
                        addQuestionClosure(fetchResults[i])
                    }
                }
                else
                {
                    addQuestionClosure(fetchResults[i])
                }
            }
            if(questions.count == 0)
            {
                var noMarkedNumbersPrompt = UIAlertController(title: "No marked numbers",
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
                
                for(var i = minCardIndex; i <= maxCardIndex ; i++)
                {
                    addQuestionClosure(fetchResults[i])
                }
            }
            questions = shuffle(questions)
        }
    }
    
    func randomNumber(range: Range<Int> = 0...99) -> Int {
        let min = range.startIndex
        let max = range.endIndex
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
    
    func getRandowAnswer(questionNotToUse:Question) -> (String)
    {
        var randNumber = randomNumber(range: 0...(questions.count - 1))
        var randomQueston = questions[randNumber]
        if(randomQueston.value == questionNotToUse.value)
        {
            randomQueston = questions[(randNumber + 1) % questions.count]
        }
        var randomAnswer = getOneRightAnswer(randomQueston)
        return randomAnswer
    }
    
    func getOneRightAnswer(question:Question) -> (String)
    {
        var randNumber = randomNumber(range: 0...(question.answers.count - 1))
        return question.answers[randNumber]
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
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
    
    func startTimer()
    {
        
        if(!timerRunning)
        {
            labelTimer.textColor = UIColor.blackColor()
            labelTimer.font = UIFont.boldSystemFontOfSize(20)
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("timerCounting"), userInfo: nil, repeats: true)
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
        self.timerCount++
        labelTimer.text = "\(self.timerCount)"
        
        if(autoreveal)
        {
            if(timerCount >= 10)
            {
                labelTimer.text = "Time up"
                timerCount = 0
                var rightAnswerButton:UIButton!
                for button in answerButtons
                {
                    if(contains(questions[currentQuestion].answers, button.titleLabel!.text!))
                    {
                        rightAnswerButton = button
                    }
                    button.enabled = false
                }
                self.animateNextQueston(rightAnswerButton)
            }
        }
    }
    
    func giveAnswer(sender: AnyObject?)
    {
        timerCount = 0
        var button = sender as UIButton
        var answerGiven = button.titleLabel?.text
        var rightAnswer = false
        for answer in questions[currentQuestion].answers
        {
            if(answerGiven == answer)
            {
                rightAnswer = true
                break
            }
        }
        animateNextQueston(button,rightAnswer: rightAnswer)
    }
    
    func animateNextQueston(button:UIButton?, rightAnswer:Bool = false)
    {
        UIView.animateWithDuration(0.5, delay: 0.0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                if(button != nil)
                {
                if(rightAnswer)
                {
                    button!.backgroundColor = UIColor.greenColor()
                    self.questionLabel.text = "😃"
                }
                else
                {
                    button!.backgroundColor = UIColor.redColor()
                    self.questionLabel.text = "😩"
                }
                }
                else
                {
                    self.questionLabel.text = "😩"
                }
            },
            completion: ({finished in
                if (finished) {
                    UIView.animateWithDuration(0.5, delay: 0.0,
                        options: UIViewAnimationOptions.CurveLinear, animations: {
                            if(button != nil)
                            {
                                button!.backgroundColor = UIColor.blackColor()
                            }
                        },completion: ({finished in
                            if (finished) {
                                self.showNextQuestion()
                                
                            }
                        }))
                }
            }))
    }
    
    func showNextQuestion()
    {
        for button in answerButtons
        {
            button.enabled = true
        }
        currentQuestion = (currentQuestion + 1) % questions.count
        
        questionLabel.text = questions[currentQuestion].value
        
        self.setAnswersOnButtons()
    }
    
    func setAnswersOnButtons()
    {
        var rightAnswerIndex = randomNumber(range: 0...4)
        var i = 0
        for answerButton in answerButtons
        {
            
            var answerText = "Did not find unique answer"
            var uniqueAnswer = false
            while uniqueAnswer == false
            {
                answerText = getRandowAnswer(questions[currentQuestion])
                if(rightAnswerIndex == i)
                {
                    answerText = getOneRightAnswer(questions[currentQuestion])
                    
                }
                for answer in answerButtons
                {
                    if(answerText != answer.titleLabel?.text)
                    {
                        uniqueAnswer = true
                    }
                }
            }
            
            answerButton.backgroundColor = UIColor.blackColor()
            answerButton.setTitle(answerText, forState: UIControlState.Normal)
            i++
        }
    }
    /*
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
        
        
        self.currentCard++
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
        
        self.currentCard--
        self.currentCard = self.currentCard < 0 ? (cards.count - 1) : self.currentCard
        labelFront.text = cards[currentCard].front
        labelBack.text = cards[currentCard].back
        
        startTimer()
    }
*/
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
