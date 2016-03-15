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

class SignupController: UIViewController, UITextFieldDelegate  {
    
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
                let regId = swiftyJsonVar["regestration_id"]
                
                //print(resData[0]["phone"])
                if(Int(resData)! == 1) {
                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                 //   prefs.setObject(self.userId, forKey: "USERID")
                    print("regId",regId.int!)
                    prefs.setInteger(1, forKey: "ISLOGGEDIN")
                    prefs.setInteger(regId.int!, forKey: "reg_id")
                    
                    let didSave = prefs.synchronize()

                    if(didSave) {
                    //    self.performSegueWithIdentifier("signup_home", sender: sender)
                        let childViewController = self.storyboard?.instantiateViewControllerWithIdentifier("follow_friends") as! FirstFollowViewController

                       // print("strFbId",strFbId)
                        
                        self.presentViewController(childViewController, animated: true, completion: nil)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    var config = configUrl()
    var url : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        lastName.delegate = self
        email.delegate = self
        password.delegate = self
        email.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        url = config.url + "new_app_service.php"
        print(url)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var keyboardStatus: Int = 0
    func keyboardWillShow(notification: NSNotification) {
        print("test",keyboardStatus)
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if(keyboardStatus == 0) {
                self.view.frame.origin.y -= 100
            }
        }
        keyboardStatus = 1
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("test1",keyboardStatus)
        keyboardStatus = 0
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            self.view.frame.origin.y += 100
            
        }
    }
    
    
}

