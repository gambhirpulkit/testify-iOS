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

class LoginController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPwd: UITextField!
    @IBOutlet var btnFacebook: FBSDKLoginButton!

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, email, gender, id, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            
            let strFirstName: String = (result.objectForKey("first_name") as? String)!
            let strLastName: String = (result.objectForKey("last_name") as? String)!
            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
            let strEmail : String = (result.objectForKey("email") as? String)!
            let strFbId: String = (result.objectForKey("id") as? String)!
            let strGender: String = (result.objectForKey("gender") as? String)!
/*
            print("strFirstName",strFirstName)
            print("strEmail",strEmail)
            print("strFbId",strFbId)
            print("strPictureURL",strPictureURL)
            print("strPictureURL",strGender)
*/
            let param = ["do": "LoginFacebook", "email": strEmail, "first_name": strFirstName,"last_name": strLastName,"password": strFbId,"imagepath": strPictureURL,"gender": strGender]
            
          //  let param = ["do": "FacebookLogin", "email": "gambhirpulkit@yahoo.co.in"]
            
            print("url",self.url!)
            Alamofire.request(.POST, self.url!, parameters: param).responseString { (responseData) -> Void in
                
             //   let swiftyJsonVar = JSON(responseData.result.value!)
                
            //    print("jsonResponse" ,swiftyJsonVar);
             //   let resData = swiftyJsonVar["ResponseCode"].stringValue
             //   print(resData)
                print("responseData",responseData.result)
                switch responseData.result {
                case .Success:
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    
                    print("jsonResponse home" ,swiftyJsonVar);
                    print("string",responseData.result.value!)
                    let jsonString = responseData.result.value!
                    if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        let json = JSON(data: dataFromString)
                        print(json["ResponseCode"])
                        let resData = json["ResponseCode"].intValue
                        
                        if(resData == 1) {
                            let activeScreen = json["Data"]["active_screen"].intValue
                            let reg_id = json["Data"]["user_id"]
                            
                            print("activeScreen",activeScreen)
                            print("reg_id",reg_id)
                            
                            if(activeScreen == 0) {
                                
                            }
                            else if(activeScreen == 1) {
                                
                            }
                            else if(activeScreen == 2) {
                                
                            }
                            else if(activeScreen == 3) {
                                
                            }
                            
                            
                        }
                        else if(resData == 2) {
                         let reg_id = json["regestration_id"].intValue
                         print("reg_id",reg_id)
                            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            //   prefs.setObject(self.userId, forKey: "USERID")
                            prefs.setInteger(1, forKey: "ISLOGGEDIN")
                            prefs.setInteger(reg_id, forKey: "reg_id")
                            prefs.setInteger(reg_id, forKey: "reg_id")
                            let didSave = prefs.synchronize()
                            
                            if(didSave) {
                                let childViewController = self.storyboard?.instantiateViewControllerWithIdentifier("update_profile") as! FbUpdateInfoController
                                    childViewController.reg_id = reg_id
                                    childViewController.fb_id = strFbId
                                    childViewController.email_id = strEmail
                                print("strFbId",strFbId)
                                
                                self.presentViewController(childViewController, animated: true, completion: nil)
                            }
                            print(prefs.integerForKey("ISLOGGEDIN"))
                        }

                    }
                    
                case .Failure(let error):
                    
                    let alert = UIAlertController(title: "No internet connection", message:"Check your internet connection and try again.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                        // PERFORM ACTION
                        })
                    self.presentViewController(alert, animated: true){}
                    print(error)
                }
                
            }

            
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        

    }
    
    //    MARK: Other Methods
    
    func configureFacebook()
    {
        btnFacebook.readPermissions = ["public_profile", "email", "user_friends"];
        btnFacebook.delegate = self
    }
    
    
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
//                        self.performSegueWithIdentifier("updateProfile", sender: self)
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
        url = config.url + "new_app_service.php"
        print(url)
        configureFacebook()
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

