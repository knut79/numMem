//
//  MainMenuViewController.swift
//  NumberMemo
//
//  Created by knut on 20/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MainMenuViewController: UIViewController{
    
    
    @IBAction func SetDataButtonPushed(sender: UIButton) {
        
        
        
        
    }
    @IBOutlet weak var FlashcardButton: UIButton!
    @IBOutlet weak var SetDataButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Now that the view loaded, we have a frame for the view, which will be (0,0,screen width, screen height)
        // This is a good size for the table view as well, so let's use that
        // The only adjust we'll make is to move it down by 20 pixels, and reduce the size by 20 pixels
        // in order to account for the status bar
        
        // Store the full frame in a temporary variable
        var viewFrame = self.view.frame
        
        // Adjust it down by 20 points
        viewFrame.origin.y += 20
        

        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
