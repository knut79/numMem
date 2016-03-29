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
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var questions:Array<Question> = Array<Question>()
    var allQuestions:Array<Question> = Array<Question>()
    var currentQuestion = 0
    
    var toggleSoundButton: UIButton!
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

        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
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
        questionLabel.adjustsFontSizeToFitWidth = true
        questionLabel.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2,y: UIScreen.mainScreen().bounds.size.height * 0.22)
        questionLabel.text = questions[currentQuestion].value
        self.view.addSubview(questionLabel)
        
        infoLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 40 * 3))
        infoLabel.textAlignment = NSTextAlignment.Center
        infoLabel.font = UIFont.boldSystemFontOfSize(10)
        infoLabel.numberOfLines = 4
        infoLabel.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width/2,y: questionLabel.frame.maxY + (labelTimer.frame.height / 2))
        
        toggleSoundButton = UIButton(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width * 0.2, UIScreen.mainScreen().bounds.size.width * 0.2))
        //toggleSoundButton.backgroundColor = UIColor.blackColor()
        toggleSoundButton.setTitle("🔇", forState: UIControlState.Normal)
        toggleSoundButton.addTarget(self, action: #selector(PlayGuessRightViewController.toggleSound), forControlEvents: UIControlEvents.TouchUpInside)
        toggleSoundButton.center = CGPointMake(UIScreen.mainScreen().bounds.size.width - (toggleSoundButton.frame.width / 2) , self.navigationController!.navigationBar.frame.maxY + (toggleSoundButton.frame.height / 2))
        //toggleSoundButton.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.height / 2)

        
        self.view.addSubview(toggleSoundButton)
        
        fetchUserData()
        
        if(staticstoreItems.count == 0)
        {
            Staticstore.createInManagedObjectContext(self.managedObjectContext!, wholenumber: "", rightnumber: "" , wrongnumber: "")
            fetchUserData()
        }
        
        setInfoLabelText()

        self.view.addSubview(infoLabel)
        self.populateAnswerButtons()
        self.setAnswersOnButtons()
        
        startTimer()
        self.view.bringSubviewToFront(toggleSoundButton)
        
    }
    var soundOn = true
    func toggleSound()
    {
        if soundOn
        {
            toggleSoundButton.setTitle("🔊", forState: UIControlState.Normal)
            //self.audioPlayer.volume = 0
        }
        else
        {
            toggleSoundButton.setTitle("🔇", forState: UIControlState.Normal)
            //self.audioPlayer.volume = 1
        }
        soundOn = !soundOn
    }
    
    func setInfoLabelText()
    {
        let bestStrike = staticstoreItems.count > 0 ? staticstoreItems[0].beststrike : 0
        infoLabel.text = " Best strike: \(bestStrike) \n Average correct time: \(self.questions[self.currentQuestion].nsManagedObject.avg) \n Answered correct: \(self.questions[self.currentQuestion].nsManagedObject.timesanswered) \n Answered wrong: \(self.questions[self.currentQuestion].nsManagedObject.timesfailed)"
    }
    
    func populateAnswerButtons()
    {
        for i in 0  ..< 5
        {
            let tempButton = UIButton(frame: CGRectMake(0, 0 , UIScreen.mainScreen().bounds.size.width, 40))
            let y = CGFloat(45 * i) + infoLabel.frame.maxY + 5
            
            tempButton.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, y)
            
            let selector: Selector = #selector(PlayGuessRightViewController.giveAnswer(_:))
            tempButton.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
            tempButton.backgroundColor = UIColor.blackColor()
            tempButton.titleLabel?.textColor = UIColor.whiteColor()
            
            answerButtons.append(tempButton)
            self.view.addSubview(tempButton)
        }
    }
    
    func addQuestion(relation:Relation, allQuestionsCollecton:Bool = false)
    {
        let questionText = relation.number +  (relation.marked == true ? self.makedString : "")
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
        
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Staticstore]
        {
            print("length of fetchResults array \(fetchResults.count)")
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
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Relation] {
            
            for relation in fetchResults
            {
                addQuestion(relation,allQuestionsCollecton: true)
                
            }
            for i in minCardIndex ... maxCardIndex
            {
                if(onlyMarked)
                {
                    if(fetchResults[i].marked == true)
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
        let randNumber = randomNumber(0...(allQuestions.count - 1))
        var randomQueston = allQuestions[randNumber]
        if(randomQueston.value == questionNotToUse.value)
        {
            randomQueston = allQuestions[(randNumber + 1) % allQuestions.count]
        }
        let randomAnswer = getOneRightAnswer(randomQueston)
        return randomAnswer
    }
    
    func getOneRightAnswer(question:Question) -> (String)
    {
        let randNumber = randomNumber(0...(question.answers.count - 1))
        return question.answers[randNumber]
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
    
    var currentCorrectAnswerStrike:Int16 = 0
    
    func startTimer()
    {
        
        if(!timerRunning)
        {
            labelTimer.textColor = UIColor.blackColor()
            labelTimer.font = UIFont.boldSystemFontOfSize(20)
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayGuessRightViewController.timerCounting), userInfo: nil, repeats: true)
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
            if(timerCount >= timeupTime)
            {
                labelTimer.text = "Time up"
                
                var rightAnswerButton:UIButton!
                for button in answerButtons
                {
                    if(questions[currentQuestion].answers.contains((button.titleLabel!.text!)))
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
        let button = sender as! UIButton
        let answerGiven = button.titleLabel?.text
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
                if(rightAnswer)
                {
                    
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOfURL: self.correctSound)
                    } catch let error1 as NSError {
                        print(error1)
                    } catch {
                        fatalError()
                    }

                    self.currentCorrectAnswerStrike += 1
                    let bestStrike = self.staticstoreItems.count > 0 ? self.staticstoreItems[0].beststrike : 0
                    if(self.currentCorrectAnswerStrike > bestStrike)
                    {
                        self.infoLabel.text = "New strike record \(self.currentCorrectAnswerStrike)"
                        self.staticstoreItems[0].beststrike = self.currentCorrectAnswerStrike
                        self.save()
                        
                    }
                    button.backgroundColor = UIColor.greenColor()
                    self.questionLabel.text = "😃"
                    let newAverage = self.calculateNewAverage()
                    
                    self.questions[self.currentQuestion].nsManagedObject.avg = newAverage
                        //+ timer) / (questions[currentQuestion].nsManagedObject.timesanswered + 1)
                    self.questions[self.currentQuestion].nsManagedObject.timesanswered = self.questions[self.currentQuestion].nsManagedObject.timesanswered + 1
                    self.save()
                    
                    //self.infoLabel.text = "Average: \(self.questions[self.currentQuestion].nsManagedObject.avg)"
                }
                else
                {
                    self.currentCorrectAnswerStrike = 0
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOfURL: self.failedSounds[self.randomNumber(0...1)])
                        
                    } catch let error1 as NSError {
                        print(error1)
                    } catch {
                        fatalError()
                    }
                    self.questions[self.currentQuestion].nsManagedObject.timesfailed = self.questions[self.currentQuestion].nsManagedObject.timesfailed + 1
                    button.backgroundColor = UIColor.redColor()
                    self.questionLabel.text = "😩"
                }

                if self.soundOn
                {
                    if(self.timerCount >= self.timeupTime)
                    {
                        do {
                            self.audioPlayer = try AVAudioPlayer(contentsOfURL: self.timeupSound)
                        } catch let error1 as NSError {
                            print(error1)
                        } catch {
                            fatalError()
                        }
                    }
                    self.audioPlayer.prepareToPlay()
                    //self.audioPlayer.volume = self.soundOn ? 1 : 0
                    self.audioPlayer.play()
                }
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
        let rightAnswerIndex = randomNumber(0...4)
        var i = 0
        for answerButton in answerButtons
        {
            
            var answerText:String!
            var uniqueAnswer = true
            var tries = 0
            repeat
            {
                tries += 1
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
                        if(answerText == answer.titleLabel?.text || questions[currentQuestion].answers.contains(answerText))
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
            i += 1
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
