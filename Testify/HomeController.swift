//
//  HomeController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 1/14/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        print(prefs.integerForKey("ISLOGGEDIN"))
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            //self.usernameLabel.text = prefs.valueForKey("USERNAME") as? String
            //let appDomain = NSBundle.mainBundle().bundleIdentifier
            //NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

