//
//  TabBarController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 2/2/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        
        if(item.tag == 0) {
            print("first clicked")
        }
        else if(item.tag == 1) {
            let vc = VideoRecordController() //change this to your class name
            self.performSegueWithIdentifier("recordControl", sender: self)
        }
    }
}