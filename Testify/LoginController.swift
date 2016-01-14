//
//  LoginController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 1/14/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginController: UIViewController {
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPwd: UITextField!
    
    @IBAction func loginBtn(sender: AnyObject) {
        if ( loginEmail.text! == "" || loginPwd.text! == "" ) {
            
            let alert = UIAlertController(title: "Sign Up Failed!", message:"Please enter all fields", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                // PERFORM ACTION
                })
            self.presentViewController(alert, animated: true){}
            
            
        }
        else {
           let param = ["do": "Login", "email": loginEmail.text!, "password": loginPwd.text!]
            
            Alamofire.request(.POST, url!, parameters: param).responseJSON { (responseData) -> Void in
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                print("jsonResponse" ,swiftyJsonVar);
                let resData = swiftyJsonVar["ResponseCode"].stringValue
                //print(resData[0]["phone"])
                if(Int(resData)! == 1) {
                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    //   prefs.setObject(self.userId, forKey: "USERID")
                    prefs.setInteger(1, forKey: "ISLOGGEDIN")
                    let didSave = prefs.synchronize()
                    
                    if(didSave) {
                        self.performSegueWithIdentifier("login_home", sender: sender)
                    }
                    print(prefs.integerForKey("ISLOGGEDIN"))
                    
                }
                else if(Int(resData)! == 2) {
                    
                    let alert = UIAlertController(title: "Sign Up Failed!", message:"Username/email already exists", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                        // PERFORM ACTION
                        })
                    self.presentViewController(alert, animated: true){}
                    
                }
                
            }
        }
        
    }
    
    var config = configUrl()
    var url : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        url = config.url + "app_services_p.php"
        print(url)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

