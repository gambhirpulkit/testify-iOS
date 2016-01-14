//
//  SignupController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 1/14/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SignupController: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBAction func goBtn(sender: AnyObject) {
        
        if ( firstName.text! == "" || lastName.text! == "" || userName.text! == "" || password.text! == "" || email.text! == "") {
            
            let alert = UIAlertController(title: "Sign Up Failed!", message:"Please enter all fields", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                // PERFORM ACTION
                })
            self.presentViewController(alert, animated: true){}
            
            
        }
        else {
           let param = ["do": "Registration", "first_name": firstName.text!, "last_name": lastName.text!, "email": email.text!,"username": userName.text!,"gender": "male",  "password": password.text!]
            
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
                        self.performSegueWithIdentifier("signup_home", sender: sender)
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

