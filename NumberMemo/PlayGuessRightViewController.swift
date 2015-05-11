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
import AVFoundation
import iAd

class PlayGuessRightViewController: UIViewController, ADBannerViewDelegate{
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var questions:Array<Question> = Array<Question>()
    var allQuestions:Array<Question> = Array<Question>()
    var currentQuestion = 0
    
    var questionLabel: UILabel!
    var infoLabel: UILabel!
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
    
    var audioPlayer = AVAudioPlayer()
    var correctSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("correct", ofType: "wav")!)
    var failedSounds = [NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("wrong1", ofType: "wav")!),NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("wrong2", ofType: "mp3")!)]
    var timeupSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("timeup", ofType: "mp3")!)

    var timeupTime:Int = 10
    
    var bannerView:ADBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.canDisplayBannerAds = true
        bannerView = ADBannerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        self.view.addSubview(bannerView!)
        self.bannerView?.delegate = self
        self.bannerView?.hidden = false
        
        // Store the full frame in a temporary variable
        var viewFrame = self.view.frame
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
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
        
        labelTimer = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 40))
        labelTimer.textAlignment = NSTextAlignment.Center
        labelTimer.font = UIFont.boldSystemFontOfSize(20)
        labelTimer.numberOfLines = 2
        labelTimer.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2,y: UIScreen.mainScreen().bounds.size.height * 0.15 )
        self.view.addSubview(labelTimer)
        
        questionLabel = UILabel(frame: CGRectMake(0, 0, 100, 60))
        questionLabel.textAlignment = NSTextAlignment.Center
        questionLabel.font = UIFont.boldSystemFontOfSize(40)
        questionLabel.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2,y: UIScreen.mainScreen().bounds.size.height * 0.22)
        questionLabel.text = questions[currentQuestion].value
        self.view.addSubview(questionLabel)
        
        infoLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 40 * 3))
        infoLabel.textAlignment = NSTextAlignment.Center
        infoLabel.font = UIFont.boldSystemFontOfSize(14)
        infoLabel.numberOfLines = 4
        infoLabel.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2,y: (UIScreen.mainScreen().bounds.size.height * 0.30) + labelTimer.frame.height)
        
        
        
        fetchUserData()
        
        setInfoLabelText()
        

        
        self.view.addSubview(infoLabel)
        
        self.populateAnswerButtons()
        
        self.setAnswersOnButtons()
        
        startTimer()
        
    }
    
    func setInfoLabelText()
    {
            infoLabel.text = " Best strike: \(staticstoreItems[0].beststrike) \n Average correct time: \(self.questions[self.currentQuestion].nsManagedObject.avg) \n Answered correct: \(self.questions[self.currentQuestion].nsManagedObject.timesanswered) \n Answered wrong: \(self.questions[self.currentQuestion].nsManagedObject.timesfailed)"
    }
    
    func populateAnswerButtons()
    {
        var rightAnswerIndex = randomNumber(range: 0...4)
        for(var i = 0 ; i < 5 ; i++)
        {
            var tempButton = UIButton(frame: CGRectMake(0, 0 , UIScreen.mainScreen().bounds.size.width, 40))
            var y = CGFloat(45 * i) + infoLabel.frame.maxY + 20
            
            tempButton.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, y)
            
            let selector: Selector = "giveAnswer:"
            tempButton.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
            tempButton.backgroundColor = UIColor.blackColor()
            tempButton.titleLabel?.textColor = UIColor.whiteColor()
            
            answerButtons.append(tempButton)
            self.view.addSubview(tempButton)
        }
    }
    
    func addQuestion(relation:Relation, allQuestionsCollecton:Bool = false)
    {
        var questionText = relation.number +  (relation.marked == 1 ? self.makedString : "")
        var answers:[String] = []
        if(relation.verb != "")
        {
            answers.append(relation.verb)
        }
        if(relation.subject != "")
        {
            answers.append(relation.subject)
        }
        if(relation.other != "")
        {
            answers.append(relation.other)
        }
        if(answers.count > 0)
        {
            if(allQuestionsCollecton)
            {
                self.allQuestions.append(Question(question: questionText, answers:answers, marked:relation.marked, nsManagedObject: relation))
            }
            else
            {
                self.questions.append(Question(question: questionText, answers:answers, marked:relation.marked, nsManagedObject: relation))
            }
        }
    }
    
    var staticstoreItems = [Staticstore]()
    
    func fetchUserData() {
        
        let fetchRequest = NSFetchRequest(entityName: "Staticstore")
        
        
        let sortDescriptor = NSSortDescriptor(key: "beststrike", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        var error: NSError?
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Staticstore]
        {
            if(error != nil)
            {
                println("Error executing request for entity \(error?.description)")
            }
            
            println("length of fetchResults array \(fetchResults.count)")
            staticstoreItems = fetchResults
        }
    }
    
    func fetchRelations() {
        
        let fetchRequest = NSFetchRequest(entityName: "Relation")
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        /*
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
        */
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Relation] {
            
            for relation in fetchResults
            {
                addQuestion(relation,allQuestionsCollecton: true)
                
            }
            for(var i = minCardIndex; i <= maxCardIndex ; i++)
            {
                if(onlyMarked)
                {
                    if(fetchResults[i].marked == 1)
                    {
                        addQuestion(fetchResults[i])
                    }
                }
                else
                {
                    addQuestion(fetchResults[i])
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
                    addQuestion(fetchResults[i])
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
        var randNumber = randomNumber(range: 0...(allQuestions.count - 1))
        var randomQueston = allQuestions[randNumber]
        if(randomQueston.value == questionNotToUse.value)
        {
            randomQueston = allQuestions[(randNumber + 1) % allQuestions.count]
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
    
    var currentCorrectAnswerStrike:Int16 = 0
    
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
            if(timerCount >= timeupTime)
            {
                labelTimer.text = "Time up"
                
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
    
    func calculateNewAverage() -> Float
    {
        return ((self.questions[self.currentQuestion].nsManagedObject.avg * Float(self.questions[self.currentQuestion].nsManagedObject.timesanswered))
            + Float(self.timerCount)) / Float(self.questions[self.currentQuestion].nsManagedObject.timesanswered + 1)
    }
    
    func animateNextQueston(button:UIButton, rightAnswer:Bool = false)
    {
        UIView.animateWithDuration(0.5, delay: 0.0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                var error:NSError?
                if(rightAnswer)
                {
                    
                    self.audioPlayer = AVAudioPlayer(contentsOfURL: self.correctSound, error: &error)

                    self.currentCorrectAnswerStrike++
                    if(self.currentCorrectAnswerStrike > self.staticstoreItems[0].beststrike)
                    {
                        self.infoLabel.text = "New strike record \(self.currentCorrectAnswerStrike)"
                        self.staticstoreItems[0].beststrike = self.currentCorrectAnswerStrike
                        self.save()
                        
                    }
                    button.backgroundColor = UIColor.greenColor()
                    self.questionLabel.text = "😃"
                    var newAverage = self.calculateNewAverage()
                    
                    self.questions[self.currentQuestion].nsManagedObject.avg = newAverage
                        //+ timer) / (questions[currentQuestion].nsManagedObject.timesanswered + 1)
                    self.questions[self.currentQuestion].nsManagedObject.timesanswered = self.questions[self.currentQuestion].nsManagedObject.timesanswered + 1
                    self.save()
                    
                    //self.infoLabel.text = "Average: \(self.questions[self.currentQuestion].nsManagedObject.avg)"
                }
                else
                {
                    self.currentCorrectAnswerStrike = 0
                    self.audioPlayer = AVAudioPlayer(contentsOfURL: self.failedSounds[self.randomNumber(range: 0...1)], error: &error)
                    self.questions[self.currentQuestion].nsManagedObject.timesfailed = self.questions[self.currentQuestion].nsManagedObject.timesfailed + 1
                    button.backgroundColor = UIColor.redColor()
                    self.questionLabel.text = "😩"
                }
                if(self.timerCount >= self.timeupTime)
                {
                    self.audioPlayer = AVAudioPlayer(contentsOfURL: self.timeupSound, error: &error)
                }
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
                self.timerCount = 0

            },
            completion: ({finished in
                if (finished) {
                    UIView.animateWithDuration(0.5, delay: 0.0,
                        options: UIViewAnimationOptions.CurveLinear, animations: {

                            button.backgroundColor = UIColor.blackColor()
                            
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
        setInfoLabelText()

        questionLabel.text = questions[currentQuestion].value
        
        self.setAnswersOnButtons()
    }
    
    func setAnswersOnButtons()
    {
        var rightAnswerIndex = randomNumber(range: 0...4)
        var i = 0
        for answerButton in answerButtons
        {
            
            var answerText:String!
            var uniqueAnswer = true
            var tries = 0
            do
            {
                tries++
                uniqueAnswer = true
                
                if(rightAnswerIndex == i)
                {
                    answerText = getOneRightAnswer(questions[currentQuestion])
                    
                }
                else
                {
                    answerText = getRandowAnswer(questions[currentQuestion])
                    for answer in answerButtons
                    {
                        if(answerText == answer.titleLabel?.text || contains( questions[currentQuestion].answers, answerText))
                        {
                            uniqueAnswer = false
                        }
                    }
                    if(tries > 30)
                    {
                        uniqueAnswer = true
                        answerText = "Did not find unique answer"
                    }
                }
            }while(uniqueAnswer == false)
            
            answerButton.backgroundColor = UIColor.blackColor()
            answerButton.setTitle(answerText, forState: UIControlState.Normal)
            i++
        }
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
