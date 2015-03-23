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
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    // Create the table view as soon as this class loads
    var relationsTableView = UITableView(frame: CGRectZero, style: .Plain)
    
    var relationItems = [Relation]()
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RelationCell") as UITableViewCell
        //cell.textLabel?.text = "\(indexPath.row)"
        
        // Get the LogItem for this index
        let relationItem = relationItems[indexPath.row]
        
        // Set the title of the cell to be the title of the logItem
        cell.textLabel?.text = relationItem.titlenumber
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let relationItem = relationItems[indexPath.row]
        
        var numberRelationPrompt = UIAlertController(title: "Enter",
            message: "Enter relation for number \(relationItem.titlenumber)",
            preferredStyle: .Alert)
        
        
        var numberRelationTextField: UITextField?
        numberRelationPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            numberRelationTextField = textField
            textField.text = relationItem.numberrelation
            textField.placeholder = "relation"
            textField.keyboardType = UIKeyboardType.NumberPad
            //textField.becomeFirstResponder()
        }
        
        numberRelationPrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                
                relationItem.numberrelation = numberRelationTextField!.text
                
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
        let sortDescriptor = NSSortDescriptor(key: "titlenumber", ascending: true)
        
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
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Relation] {
            relationItems = fetchResults
        }
    }
    
    let addItemAlertViewTag = 0
    let addItemTextAlertViewTag = 1
    func addNewItem() {
        
        var numberPrompt = UIAlertController(title: "Enter",
            message: "Enter number with relation",
            preferredStyle: .Alert)
        
        var numberTextField: UITextField?
        numberPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            numberTextField = textField
            textField.placeholder = "Number"
            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        
        var relationTextField: UITextField?
        numberPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            relationTextField = textField
            textField.placeholder = "relation"
            textField.keyboardType = UIKeyboardType.Default
        }

        
        numberPrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                //let textField = numberTextField
                if(numberTextField != nil && relationTextField != nil)
                {
                    self.saveNewItem(numberTextField!.text,relation: relationTextField!.text)
                }
        }))
        
        self.presentViewController(numberPrompt,
            animated: true,
            completion: nil)
    }
    
    
    
    func populateItems() {
        
        var testData = [
            ("00","Ozzy Ozbourne"),
            ("01","OIl"),
            ("02","OTer"),
            ("03","jOEy"),
            ("04","ORangutang . play an ORgan"),
            ("05","OSama bin laben"),
            ("06","augustus OCtavian. an OCtopus"),
            ("07","OLivia. OLives"),
            ("08","bOA snake. BOard a ship"),
            ("09","jOGger. yOuGhurt"),
            ("10","diego maradonna. IOc member gerard heiberg")
        ]
        
        /*
        00 ozzy ozbourne object orientering på tavle
        
        01 mann kledd ut som oljetønne sort olje
        
        02 oter/otto Jespersen fotografere
        
        03 joey obay
        
        04 orangutang spille orgel
        
        05 osama bin laden/ostemann ostehøvle
        
        06 augustus octavian octopus
        
        07 olivia d rio plukke oliven fra oliventre,olivenolje, olabil
        
        08 boa-slange/ola boarde et fly
        
        09 original gansta/joggedame jonglere
        
        10 ioc medlem gerard heiberg maradonnas drakt/modell av jupiter månen io
        
        11 vinni/mann kledd ut som wii spille wii
        
        12 it-girl(liverly) eat
        
        13 mann kledd ut som bie/bie vie/sklie
        
        14 ironman holde et kart over iran/irak
        
        15 isla fisher/isbjørn isfiske/iscreme seg
        
        16 iker casillas spille icehockey
        
        17 ilder ildsåsettelse
        
        18 ian thorp/ida alstad piano
        
        19 iglesias ligge i iglo, på line
        
        20 tone damli kjøre lite tog tommestokk
        
        21 tindra/tiger tigge/tiger
        
        22 tung transport(optimus prime) trailer tute, tt-b
        
        23 terrorist telefonere, teppe, teleskop, terese johaug, te
        
        24 troll trikse med ball, trampoline
        
        25 tsar/tiss tusje
        
        26 tchadeser/Tchave dekke seg til (tchadde seg til)
        
        27 tori la. spyder turnament level
        
        28 tarzan,tara, taylor p, tarantino tapetsere, tanks
        
        29 trond giske tægge 30 demon devon demonstrere 31 eirin/einstein heise
        
        32 E.T etablere skyte stilling 33 erica eleniac peele en kylling 34 eremitt, erik solheim erteblåser,eremitt 35 erna solberg esel, ese 36 ekkorn/echo jhonson ekko 37 elinaG/elle mc /elg/elge/elske
        
        38 neandertaler heale/ejakulere????? 39 egil(herberge) egge 40 robot ro en båt 41 riannon ri en hest 42 rytter(klovn) ruteknuse /ert 43 rev/rekdal rengjøre/re (en seng) 44 radioResepsjonen røre i grøt 45 russ russeknute
        
        46 røkke/rc cola røke/rc cola/ rc fly bil båt
        
        47 rebecca lin rullator skate (rulle på rullebrett) 48 rakel Rapper nordtønne rake 49 rugbyspiller ruge (på et egg)
        
        50 sol/sofia sole seg sopelim
        
        51 silvio berlusconi / sigvard d./idol siri/sild/sikle, sint, sirup
        
        52 stacy/(steinar) stirre/stylter
        
        53 sel segle/sepe, sene, selena g, serina w, sangeren seal
        
        54 shrek surfe 55 ss-soldat/susanne Wergeland steven seagal/sharon stone susse/sakse/sissers 56 skiløper skyte 57 slave/slim/ slikke 58 savannah sage same sau
        
        59 sugge sugerør subaru
        
        60 cowboy/cowgirl/kortney kane koste 61 kirsebom/kirsten/kiropraktor kite
        
        62 katy kutte opp koteletter . Sete
        
        63 keri ketchup 64 kristus krabbe , krans
        
        65 kiss spille cs/male seg som kiss 66 cindy crawford cyclecomponents 67 claudia shiffer klatre/klore/klistre klistremerker
        
        68 carmen/karen kaste kake/kakekrig
        
        69 Carl Gustav,sega konsoll spille sega konsoll/SAGGE
        
        70 lolita lollipop, lotus
        
        71 linn/ Linda o/gå line lime
        
        72 luther king lytte med stetoskop/ elte deig
        
        73 lexus l / Leopard/ lese
        
        74 lyriker/lur blåse i lur 75 løs hund/ls /lydia Sch. /kebab/lås låse 76 lc else koss furuseth lukeparkere 77 louise lane,lars lillo, lulle seg til en ball 78 larsåsen lassokasting/latex
        
        79 lady gaga/lg , elg ioskjerm ligge med henda bak hodet
        
        80 mao aa aorta som blør, 80 talls samanta fox frisyre
        
        81 aileen airconditionere
        
        82 atle antonsen atombombe, atlas 
        
        83 ape amme Ake
        
        84 argentiner, b franco tegne på et arkitektbord
        
        85 aslak sira myre asfaltere
        
        86 akrobat ?? /aksel hennie ake
        
        87 alicia keys, aleska holde en almanak , 
        
        88 asia akira, anonym alkoholiker veive med pekefinger ahah 89, agulera aggie (frost) holde en agurk 90 gary oldman/golfspiller/gulbis golfe 91 giselle giraff gir 92 gina turner/golf GT gin and tonic
        
        93 geri halleway/GEIR gebisspussing gepard
        
        94 gris/jana grishen/grichen/ grille 95 gørill snorreggen/guenn stefani/gås gåsedun-krig 96 geek gjøkur
        
        97 Gerd liv Valla  / geir lippestad.gløde / glenn roar / gløde/ glavarull
        
        98 gemma arterton/gave/gamsten/gargamel 99 gina g google/gagge/flagge
        */
        var numberPrompt = UIAlertController(title: "Populate data",
            message: "Want to populate some test data",
            preferredStyle: .Alert)

        numberPrompt.addAction(UIAlertAction(title: "YES",
            style: .Default,
            handler: { (action) -> Void in
                for values in testData
                {
                    self.saveNewItem(values.0,relation: values.1)
                    
                }

        }))
        
        numberPrompt.addAction(UIAlertAction(title: "NO",
            style: .Default,
            handler: { (action) -> Void in
                return
        }))
        
        self.presentViewController(numberPrompt,
            animated: true,
            completion: nil)
    }
    
    
    func saveNewItem(number: String, relation: String) {
        // Create the new  log item
        
        var newRelationItem = Relation.createInManagedObjectContext(self.managedObjectContext!, thenumber: number, therelation: relation)
        
        // Update the array containing the table view row data
        self.fetchRelations()
        
        // Animate in the new row
        // Use Swift's find() function to figure out the index of the newLogItem
        // after it's been added and sorted in our logItems array
        if let newItemIndex = find(relationItems, newRelationItem) {
            // Create an NSIndexPath from the newItemIndex
            let newRelationItemIndexPath = NSIndexPath(forRow: newItemIndex, inSection: 0)
            // Animate in the insertion of this row
            relationsTableView.insertRowsAtIndexPaths([ newRelationItemIndexPath ], withRowAnimation: .Automatic)
            save()
        }
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
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
        let addButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        addButton.setTitle("+", forState: .Normal)
        addButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        addButton.addTarget(self, action: "addNewItem", forControlEvents: .TouchUpInside)
        self.view.addSubview(addButton)
        
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

