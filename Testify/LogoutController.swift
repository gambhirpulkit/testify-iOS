//
//  LogoutController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 1/15/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import UIKit

class LogoutController: UIViewController {
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
