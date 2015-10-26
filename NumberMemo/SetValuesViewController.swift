//
//  ViewController.swift
//  NumberMemo
//
//  Created by knut on 15/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit
import CoreData

class SetValuesViewController: UIViewController, UITableViewDataSource  , UITableViewDelegate{


    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    // Create the table view as soon as this class loads
    var relationsTableView = UITableView(frame: CGRectZero, style: .Plain)
    
    var relationItems = [Relation]()
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RelationCell")
        //cell.textLabel?.text = "\(indexPath.row)"
        
        // Get the LogItem for this index
        let relationItem = relationItems[indexPath.row]
        
        // Set the title of the cell to be the title of the logItem
        let allValuesSat = relationItem.subject != "" && relationItem.verb != ""
       
        var textForCell:String!
        if(allValuesSat)
        {
            textForCell = relationItem.number + " : " + "😀"
        }
        else
        {
            let subjectSat = relationItem.subject != ""
            let verbSat = relationItem.verb != ""
            let noValuesSat = !subjectSat && !verbSat
            let text = noValuesSat ? "No verb or subject 😟" :  (subjectSat ? "Subject😊" : "No subject😕") + " " + (verbSat ? "Verb😊" : "No verb😕")

            textForCell = relationItem.number + " : " + text
        }
        cell!.textLabel?.text = textForCell
        return cell!
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let relationItem = relationItems[indexPath.row]
        
        let numberRelationPrompt = UIAlertController(title: "Enter",
            message: "Enter relations for number \(relationItem.number)",
            preferredStyle: .Alert)
        
        
        var subjectRelationTextField: UITextField?
        numberRelationPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            subjectRelationTextField = textField
            textField.text = relationItem.subject
            textField.placeholder = "subject relation"
            textField.keyboardType = UIKeyboardType.Default
        }
        
        var verbRelationTextField: UITextField?
        numberRelationPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            verbRelationTextField = textField
            textField.text = relationItem.verb
            textField.placeholder = "verb relation"
            textField.keyboardType = UIKeyboardType.Default
        }
        
        var otherRelationTextField: UITextField?
        numberRelationPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            otherRelationTextField = textField
            textField.text = relationItem.other
            textField.placeholder = "other relation"
            textField.keyboardType = UIKeyboardType.Default
        }
        
        numberRelationPrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                
                relationItem.subject = subjectRelationTextField!.text!
                relationItem.verb = verbRelationTextField!.text!
                relationItem.other = otherRelationTextField!.text!
                self.save()
                //let textField = numberTextField
                /*
                if(numberTextField != nil && relationTextField != nil)
                {
                    self.saveNewItem(numberTextField!.text,relation: relationTextField!.text)
                }
                */
        }))
        
        self.presentViewController(numberRelationPrompt,
            animated: true,
            completion: nil)
        
        //println(relationItem.numberrelation)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the LogItem object the user is trying to delete
            let relationItemToDelete = relationItems[indexPath.row]
            
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(relationItemToDelete)
            
            // Refresh the table view to indicate that it's deleted
            self.fetchRelations()
            
            // Tell the table view to animate out that row
            relationsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            save()
        }
    }
    
    func fetchRelations() {
        
        // Create a new fetch request using the LogItem entity
        // eqvivalent to select * from Relation
        let fetchRequest = NSFetchRequest(entityName: "Relation")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        /*
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        //let predicate = NSPredicate(format: "titlenumber == %@", "Best Language")?.description
        let predicate = NSPredicate(format: "titlenumber contains %@", "Worst")
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate*/
        
        /*
        //combining predicates
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let firstPredicate = NSPredicate(format: "title == %@", "Best Language")
                // Search for only items using the substring "Worst"
        let thPredicate = NSPredicate(format: "title contains %@", "Worst")
        // Combine the two predicates above in to one compound predicate
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [firstPredicate, thPredicate])
        */
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Relation] {
            relationItems = fetchResults
        }
    }
    
    let addItemAlertViewTag = 0
    let addItemTextAlertViewTag = 1
    func addNewItem() {

        let numberPrompt = UIAlertController(title: "Enter",
            message: "Enter number with relations",
            preferredStyle: .Alert)
        
        var numberTextField: UITextField?
        numberPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            numberTextField = textField
            textField.placeholder = "Number"
            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        
        var subjectRelationTextField: UITextField?
        numberPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            subjectRelationTextField = textField
            textField.placeholder = "subject relation"
            textField.keyboardType = UIKeyboardType.Default
        }
        var verbRelationTextField: UITextField?
        numberPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            verbRelationTextField = textField
            textField.placeholder = "verb relation"
            textField.keyboardType = UIKeyboardType.Default
        }
        var otherRelationTextField: UITextField?
        numberPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            otherRelationTextField = textField
            textField.placeholder = "other relations"
            textField.keyboardType = UIKeyboardType.Default
        }

        
        numberPrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                //let textField = numberTextField
                if(numberTextField != nil && (subjectRelationTextField != nil || verbRelationTextField != nil || otherRelationTextField != nil))
                {
                    let numberAsInt = Int(numberTextField!.text!)
  
                    if( numberAsInt == nil )
                    {
                        let existsPrompt = UIAlertController(title: "Not valid number",
                            message: "Value \(numberTextField!.text!) must be of type integer",
                            preferredStyle: .Alert)
                        existsPrompt.addAction(UIAlertAction(title: "Ok",
                            style: .Default,
                            handler: nil))
                        self.presentViewController(existsPrompt,
                            animated: true,
                            completion: nil)
                    }
                    else if(self.numberExists(String(numberAsInt)))
                    {
                        let existsPrompt = UIAlertController(title: "Value exists",
                            message: "Number \(String(numberAsInt)) exists. Values are dismissed",
                            preferredStyle: .Alert)
                        existsPrompt.addAction(UIAlertAction(title: "Ok",
                            style: .Default,
                            handler: nil))
                        self.presentViewController(existsPrompt,
                            animated: true,
                            completion: nil)
                    }
                    else
                    {
                        //numberTextField!.text
                        //self.saveNewItem(values.0,relationsubject: values.1, relationverb: values.2, otherrelation: values.3)
                    
                        self.saveNewItem(String(numberAsInt), relationsubject: subjectRelationTextField != nil ?  subjectRelationTextField!.text! : "",relationverb: verbRelationTextField != nil ?  verbRelationTextField!.text! : "" , otherrelation: otherRelationTextField != nil ? otherRelationTextField!.text! : "")
                    }
                }
        }))
        

        
        self.presentViewController(numberPrompt,
            animated: true,
            completion: nil)
        
        relationsTableView.reloadData()
    }
    
    func infoAction()
    {
        let existsPrompt = UIAlertController(title: "Info",
            message: "Set relational values to numbers. As numbers are abstract in nature, visualizing them through objects and activities will make them easier to remember. Tip: sett values according to a digits relation to a letter. 0 = O , 1 = I, 2 = T, 3 = E, 4 = R, 5 = S, 6 = c, 7 = l, 8 = a , 9 = g.  Eg. 68 = camilla 32 = Eat. 6832 = camilla is eating",
            preferredStyle: .Alert)
        existsPrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: nil))
        self.presentViewController(existsPrompt,
            animated: true,
            completion: nil)
    }
    
    func numberExists(number: String) -> Bool
    {
        for relation in relationItems
        {
            if(number == relation.number)
            {
                return true
            }
        }
        return false
    }
    
    func populateItems() {
        
        let testData = [
            ("00","Ozzy Ozbourne","Organizing Oxen",""),
            ("01","Man dressed as Oil barrel","",""),
            ("02","Otter","Building a otter dam",""),
            ("03","jOEy (from friends)","Obay a god",""),
            ("04","ORangutan","play an ORgan",""),
            ("05","OSama bin laben","Looking at an OScilloscope",""),
            ("06","OCtopus ","Using OCulus rift",""),
            ("07","OLivia","Picking OLives",""),
            ("08","bOA snake","BOard a ship",""),
            ("09","","jOGging/eating yOuGhurt",""),
            ("10","diego maradonna(number 10)","using ion cannon",""),
            
            ("11","vInnIe jones","playing wii",""),
            ("12","IT(the clown)","to eat",""),
            ("13","","using Internet Explorer",""),
            ("14","IRonman","casting IRon",""),
            ("15","","standing on a small ISland",""),
            ("16","","standing on a iceflake","Icecreme"),
            ("17","","pushing illegal drugs",""),
            ("18","IAn thorp","play the pIAno",""),
            ("19","","stay in an IGloo",""),
            ("20","Tommy","wearing a TOga",""),
            
            ("21","TIger","TIpsing",""),
            ("22","","playing TableTennis","audi TT"),
            ("23","nicola TEsla","using a TElescope",""),
            ("24","TRoll","riding a TRain",""),
            ("25","TSar nicholas 2.","",""),
            ("26","a guy from TChad/Tchad","playing in a desert",""),
            ("27","","",""),
            ("28","TArzan/TArantino","TAgging a cow","TAnks"),
            ("29","TG","",""),
            ("30","dEmOn","dEmOnstrate",""),
            
            ("31","EInstein","",""),
            ("32","E.T","cycling with ET in a basket",""),
            ("33","","pEEling a chicken ",""),
            ("34","Eric","eradicate a wasp nest",""),
            ("35","emilio EStefan","taking an escalator",""),
            ("36","","yelling out an echo",""),
            ("37","ellen","getting an electric shock",""),
            ("38","nEAndertal","",""),
            ("39","EGor","throw an egg",""),
            ("40","RObot","row a boat",""),
            
            ("41","rianna","rideing a horse",""),
            ("42","rytter","ruteknuser","ert"),
            ("43","","",""),
            ("44","radioresepsjonen","røre i grøt",""),
            ("45","","rugby",""),
            ("46","","","rc cola"),
            ("47","rebecca","",""),
            ("48","rambo","",""),
            ("49","","rugby",""),
            ("50","sofia","",""),
            
            ("51","silvio berlusconi","","sirup"),
            ("52","stacy","",""),
            ("53","seal","",""),
            ("54","shrek","surf",""),
            ("55","steven seagal/sharon stone","",""),
            ("56","","",""),
            ("57","","",""),
            ("58","","",""),
            ("59","","",""),
            ("60","kortney","","cowboy"),
            
            ("61","","kite","kiropraktor"),
            ("62","katy perry","",""),
            ("63","keri","ketchup",""),
            ("64","","",""),
            ("65","kiss","male seg som kiss",""),
            ("66","cindy crawford","",""),
            ("67","claudia shiffer",""," "),
            ("68","karen","",""),
            ("69","","","sega"),
            ("70","loren","","lotus"),
            
            ("71","linda","",""),
            ("72","luther king","",""),
            ("73","Leopard","","lexus car"),
            ("74","shakespear","",""),
            ("75","","",""),
            ("76","elisa","",""),
            ("77","louise lane","",""),
            ("78","lamar","","latex"),
            ("79","Lady Gaga","",""),
            ("80","mao","",""),
            
            
            ("81","aileen","","aircondition"),
            ("82","","","atombomb"),
            ("83","ape","amme",""),
            ("84","","",""),
            ("85","","",""),
            ("86","","",""),
            ("87","alicia keys","",""),
            ("88","","",""),
            ("89","","",""),
            ("90","gary oldman","play GOlf","golf"),
            
            
            ("91","giraf","",""),
            ("92","gina turner","","gin and tonic"),
            ("93","geri halleway","","gepard"),
            ("94","","",""),
            ("95","guenn stefani","",""),
            ("96","","","geek"),
            ("97","","",""),
            ("98","","",""),
            ("99","","","")
        ]
        /*var testData = [
            ("00","Ozzy Ozbourne","",""),
            ("01","Oil","",""),
            ("02","Oter","",""),
            ("03","jOEy","",""),
            ("04","ORangutang","play an ORgan",""),
            ("05","OSama bin laben","",""),
            ("06","augustus OCtavian. an OCtopus","",""),
            ("07","OLivia. OLives","",""),
            ("08","bOA snake","BOard a ship",""),
            ("09","yOuGhurt","jOGge",""),
            ("10","diego maradonna. IOc member gerard heiberg","",""),
            
            ("11","vinni","spille wii",""),
            ("12","it-girl(liverly)","eat",""),
            ("13","bie","vie","sklie"),
            ("14","ironman","holde kart over irak",""),
            ("15","isla fisher/isbjørn","isfiske","iscreme"),
            ("16","iker casillas","spille icehockey",""),
            ("17","ilder","ildspåsettelse",""),
            ("18","ian thorp/ida alstad","spille piano",""),
            ("19","iglesias","ligge i iglo",""),
            ("20","tone damli","kjøre tog","tommestokk"),
            
            ("21","tindra/tiger","tigge",""),
            ("22","TT optimus prime","trailer tute",""),
            ("23","terrorist","telefonere","teppe , teleskop, terese j"),
            ("24","troll","trampoline / trikse med ball",""),
            ("25","tsar","tisse/tusje",""),
            ("26","tchadeser/Tchave","tchadde seg til",""),
            ("27","tori la","spyder turnament level",""),
            ("28","tarzan,tarantino","tapetsere","tanks"),
            ("29","trond giske","tægge",""),
            ("30","demon devon","demonstrere",""),
            
            ("31","eirin/einstein","heise",""),
            ("32","E.T","Stablere skyte stilling",""),
            ("33","Erica eleniac","peele en kylling",""),
            ("34","eremitt / Erik solheim","erteblåser",""),
            ("35","erna solberb / Esel","ese",""),
            ("36","echo jhonson / ekkorn","ekkolodd",""),
            ("37","elle mc / elg","elske/elge","elina g"),
            ("38","neandertaler","ejakulere",""),
            ("39","egil","egge",""),
            ("40","robot","ro en båt",""),
            
            ("41","riannon","ri en hest",""),
            ("42","rytter","ruteknuser","ert"),
            ("43","rekdal / rev","rengjøre / re en seng",""),
            ("44","radioresepsjonen","røre i grøt",""),
            ("45","russ","rugby","russebuss"),
            ("46","røkke","røyke","rc cola"),
            ("47","rebecca lin","","rullator"),
            ("48","rakel nordtønne","rake",""),
            ("49","","rugby / ruge på egg",""),
            ("50","sofia","sole seg","sopelim"),
            
            ("51","silvio berlusconi / sild","sikle / sint","sirup"),
            ("52","steinar / stacy","stirre / stylter",""),
            ("53","seal (sangeren) / sel","sepe",""),
            ("54","shrek","surfe",""),
            ("55","susanne wegeland/steven seagal/sharon Stone","sakse",""),
            ("56","","skyte","skiløper"),
            ("57","slave","slikke / slim",""),
            ("58","savanna / sau","sage","samedrakt"),
            ("59","sugge(hu i 2 and a half)","sugerør","subaru"),
            ("60","kortney kane","koste","cowboy"),

            ("61","kirsebom","kite","kiropraktor"),
            ("62","katy perry","kutte opp koteletter",""),
            ("63","keri","ketchup",""),
            ("64","kristus / krabbe","krans",""),
            ("65","kiss /kirsten","male seg som kiss",""),
            ("66","cindy crawford","","cyclecomponents"),
            ("67","claudia shiffer","klatre/klore","klistre "),
            ("68","carmen / karen","kaste kake",""),
            ("69","carl gustav","sægge","sega"),
            ("70","lolita","lollipop","lotus"),
            
            ("71","linda / line","gå på line",""),
            ("72","luther king","lytte(m stetoskop)",""),
            ("73","Leopard /lexus l","lese","lexus"),
            ("74","(shakespear)","ta en lur/ plåse i lur","lyriker"),
            ("75","løshund lydia S","låse seg fast","kebab"),
            ("76","else koss","lukeparkere",""),
            ("77","louise lane","lulle seg til en ball",""),
            ("78","larsåsen","lassokasting","latex"),
            ("79","lady gaga / elg","",""),
            ("80","forman mao","","aorta"),

            
            ("81","aileen","","aircondition"),
            ("82","atle antonsen","","atombombe"),
            ("83","ape","amme",""),
            ("84","argentiner/ b franco","","arkitektsbord"),
            ("85","aslak sira myre","asfaltere",""),
            ("86","aksel hennie","ake","akrobat"),
            ("87","alicia keys / aleska","","almanak"),
            ("88","asia akira","veive med pekefinger ahahah",""),
            ("89","agulera/aggie","","agurk"),
            ("90","gary oldman","","golf/golfspiller"),
            
        
            ("91","giselle / giraf","",""),
            ("92","gina turner","","gin and tonic"),
            ("93","geri halleway/ geir","","gepard/ gebiss"),
            ("94","grichen / gris","grille",""),
            ("95","guenn stefani/gås","","gåsedun"),
            ("96","","","gjøkur / geek"),
            ("97","glenn / gerd liv valla","gløde","glavarull"),
            ("98","gamsten/gargamel","","gave"),
            ("99","gina G","","flagge")
        ]*/
        
        let numberPrompt = UIAlertController(title: "Set relations",
            message: "Some example data is given. Set your own values",
            preferredStyle: .Alert)

        numberPrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                for values in testData
                {
                    self.saveNewItem(values.0,relationsubject: values.1, relationverb: values.2, otherrelation: values.3)
                    
                }

        }))
        /*
        numberPrompt.addAction(UIAlertAction(title: "NO",
            style: .Default,
            handler: { (action) -> Void in
                return
        }))
        */
        
        self.presentViewController(numberPrompt,
            animated: true,
            completion: nil)
    }
    
    
    func saveNewItem(number: String, relationsubject: String, relationverb: String, otherrelation: String ) {
        // Create the new  log item
        
        let newRelationItem = Relation.createInManagedObjectContext(self.managedObjectContext!, number: number, verb: relationverb, subject: relationsubject, otherrelation: otherrelation)
        
        // Update the array containing the table view row data
        self.fetchRelations()
        
        // Animate in the new row
        // Use Swift's find() function to figure out the index of the newLogItem
        // after it's been added and sorted in our logItems array
        if let newItemIndex = relationItems.indexOf(newRelationItem) {
            // Create an NSIndexPath from the newItemIndex
            let newRelationItemIndexPath = NSIndexPath(forRow: newItemIndex, inSection: 0)
            // Animate in the insertion of this row
            relationsTableView.insertRowsAtIndexPaths([ newRelationItemIndexPath ], withRowAnimation: .Automatic)
            save()
        }
    }
    
    func save() {
        do{
            try managedObjectContext!.save()
        } catch {
            print(error)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        /*
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Relation", inManagedObjectContext: self.managedObjectContext!) as Relation
        newItem.titlenumber = "Wrote Core Data Tutorial"
        newItem.numberrelation = "Wrote and post a tutorial on the basics of Core Data to blog."
*/
        // Use optional binding to confirm the managedObjectContext
/*
        if let moc = self.managedObjectContext {
            
            // Create some dummy data to work with
            var items = [
                ("Best Animal", "Dog"),
                ("Best Language","Swift"),
                ("Worst Animal","Cthulu"),
                ("Worst Language","LOLCODE")
            ]
            
            // Loop through, creating items
            for (itemTitle, itemText) in items {
                // Create an individual item
                Relation.createInManagedObjectContext(moc,
                    thenumber: itemTitle, therelation: itemText)
            }
        }
*/
        // Print it to the console
        //println(managedObjectContext)
        
        // Now that the view loaded, we have a frame for the view, which will be (0,0,screen width, screen height)
        // This is a good size for the table view as well, so let's use that
        // The only adjust we'll make is to move it down by 20 pixels, and reduce the size by 20 pixels
        // in order to account for the status bar
        
        // Store the full frame in a temporary variable
        var viewFrame = self.view.frame
        
        // Adjust it down by 20 points
        viewFrame.origin.y += ( self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height )
        
        // Add in the "+" button at the bottom
        let margin:CGFloat = 2
        let addButton = UIButton(frame: CGRectMake(margin, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width * 0.8, 44))
        addButton.setTitle("+", forState: .Normal)
        addButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        addButton.addTarget(self, action: "addNewItem", forControlEvents: .TouchUpInside)
        self.view.addSubview(addButton)
        
        let infoButton = UIButton(frame: CGRectMake(addButton.frame.maxX + margin , UIScreen.mainScreen().bounds.size.height - 44, (UIScreen.mainScreen().bounds.size.width * 0.2) - (margin * 3), 44))
        infoButton.setTitle("ℹ", forState: .Normal)
        infoButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        infoButton.addTarget(self, action: "infoAction", forControlEvents: .TouchUpInside)
        self.view.addSubview(infoButton)
        
        // Reduce the total height by 20 points for the status bar, and 44 points for the bottom button
        viewFrame.size.height -= (self.navigationController!.navigationBar.frame.size.height +
            UIApplication.sharedApplication().statusBarFrame.size.height + addButton.frame.size.height)
        
        // Set the logTableview's frame to equal our temporary variable with the full size of the view
        // adjusted to account for the status bar height
        relationsTableView.frame = viewFrame
        
        // Add the table view to this view controller's view
        self.view.addSubview(relationsTableView)
        
        // Here, we tell the table view that we intend to use a cell we're going to call "LogCell"
        // This will be associated with the standard UITableViewCell class for now
        relationsTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "RelationCell")
        
        // This tells the table view that it should get it's data from this class, ViewController
        relationsTableView.delegate = self
        relationsTableView.dataSource = self
        
        
        
        fetchRelations()
        
        if(relationItems.count == 0)
        {
            self.populateItems()
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
        // Create a new fetch request using the LogItem entity
        // eqvivalent to select * from Relation
        let fetchRequest = NSFetchRequest(entityName: "Relation")

        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Relation] {
            
            
            // Create an Alert, and set it's message to whatever the itemText is
            let alert = UIAlertController(title: fetchResults[0].titlenumber,
                message: fetchResults[0].numberrelation,
                preferredStyle: .Alert)
            
            // Display the alert
            self.presentViewController(alert,
                animated: true,
                completion: nil)

        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

