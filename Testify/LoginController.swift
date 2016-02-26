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

class LoginController: UIViewController, UITextFieldDelegate {
    
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
                let regId = swiftyJsonVar["Data"]["user_id"].stringValue
                print("regId login",regId)
                //print(resData[0]["phone"])
                if(Int(resData)! == 1) {
                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    //   prefs.setObject(self.userId, forKey: "USERID")
                    prefs.setInteger(1, forKey: "ISLOGGEDIN")
                    prefs.setInteger(Int(regId)!, forKey: "reg_id")
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
        loginEmail.delegate = self
        loginPwd.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
            
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    


        // Do any additional setup after loading the view, typically from a nib.
        url = config.url + "app_services_p.php"
        print(url)
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
            self.view.frame.origin.y -= keyboardSize.height
            }
        }
                keyboardStatus = 1
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("test1",keyboardStatus)
        keyboardStatus = 0
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            self.view.frame.origin.y += keyboardSize.height
            
        }
    }
    
}

