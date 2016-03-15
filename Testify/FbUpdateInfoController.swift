//
//  FbUpdateInfoController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 3/12/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Haneke

class FbUpdateInfoController: UIViewController, UITextFieldDelegate {
    
    var reg_id:Int?
    var fb_id:String?
    var email_id:String?
    
    var user_gender = ""
    
    @IBOutlet var fbImg: UIImageView!
    @IBOutlet var fName: UITextField!
    @IBOutlet var lName: UITextField!
    @IBOutlet var username: UITextField!
    
    @IBOutlet var maleBtn: UIButton!
    @IBOutlet var femaleBtn: UIButton!
    
    @IBOutlet var aboutUser: UITextField!
    
    @IBOutlet var submitBtn: UIButton!
    
    var image_link: String?
    
    var config = configUrl()
    var url : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("reg_id",reg_id)
        print("fb_id",fb_id)
        
        url = config.url + "new_app_service.php"
        print(url)
        
        let param = ["do": "LoginFacebook", "email": email_id!, "password": fb_id!]
        
        Alamofire.request(.POST, url!, parameters: param).responseString { (responseData) -> Void in
            
            //   let swiftyJsonVar = JSON(responseData.result.value!)
            
            //    print("jsonResponse" ,swiftyJsonVar);
            //   let resData = swiftyJsonVar["ResponseCode"].stringValue
            //   print(resData)
            print("responseData",responseData.result)
            switch responseData.result {
            case .Success:
                let swiftyJsonVar = JSON(responseData.result.value!)
                
              //  print("jsonResponse home" ,swiftyJsonVar);
                print("string",responseData.result.value!)
                let jsonString = responseData.result.value!
                if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    print(json["ResponseCode"])
                    let resData = json["ResponseCode"].intValue
                    let f_name = json["Data"]["first_name"].stringValue
                    let l_name = json["Data"]["last_name"].stringValue
                    self.image_link = json["Data"]["imagepath"].stringValue
                    let gender = json["Data"]["gender"].stringValue
                    
                    if(f_name != "") {
                        self.fName.text! = f_name
                    }
                    if(l_name != "") {
                        self.lName.text! = l_name
                    }
                    let image_url = NSURL(string: self.image_link!)
                    
                    self.fbImg.layer.borderWidth = 1
                    self.fbImg.layer.masksToBounds = true
                    self.fbImg.layer.borderColor = UIColor.blackColor().CGColor
                    self.fbImg.layer.cornerRadius = self.fbImg.frame.height/2
                    self.fbImg.clipsToBounds = true
                    self.fbImg.hnk_setImageFromURL(image_url!)
                    
                    if(gender != "") {
                        
                        self.user_gender = gender
                        
                        print("genderCheck",self.user_gender)
                        if(self.user_gender == "male") {
                            // femaleBtn.transform = CGAffineTransformMakeScale(1,1)
                            UIButton.setAnimationDuration(0.6)
                            self.maleBtn.transform = CGAffineTransformMakeScale(1.5,1.5)
                        }
                        if(self.user_gender == "female") {
                            //  maleBtn.transform = CGAffineTransformMakeScale(1,1)
                            UIButton.setAnimationDuration(0.6)
                            self.femaleBtn.transform = CGAffineTransformMakeScale(1.5,1.5)
                        }

                    }
                
                    
                    
                    
                    print("resData",resData)

                    
                    
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
        
        
        submitBtn.addTarget(self, action: "submitAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        fName.delegate = self
        lName.delegate = self
        username.delegate = self
        aboutUser.delegate = self
        
    //    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    //    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        maleBtn.addTarget(self, action: "maleAction:", forControlEvents: UIControlEvents.TouchUpInside)
        femaleBtn.addTarget(self, action: "femaleAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
    } //END OF VIEWDIDLOAD
    
    
    func submitAction(sender: UIButton) {
        
   //     print("bc",user_gender)
        
        if(user_gender == "" || fName.text! == "" || lName.text! == "" || username.text! == "") {

            
            let alert = UIAlertController(title: "Update Failed!", message:"Please enter all fields", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                // PERFORM ACTION
                })
            self.presentViewController(alert, animated: true){}
            
        }
        else {
            let username_val = username.text!
            if(username_val.characters.count >= 5 && checkTextSufficientComplexity(username_val) && username_val.characters.count <= 15) {
                
                let param = ["do": "update_profile", "user_id": reg_id!, "first_name": fName.text!, "last_name": lName.text!, "username": username_val, "password": fb_id!, "gender": user_gender, "about_me": aboutUser.text!,"imagepath": image_link!]
                
                Alamofire.request(.POST, url!, parameters: param as! [String : AnyObject]).responseJSON { (responseData) -> Void in
                    
                    //   let swiftyJsonVar = JSON(responseData.result.value!)
                    
                    //    print("jsonResponse" ,swiftyJsonVar);
                    //   let resData = swiftyJsonVar["ResponseCode"].stringValue
                    //   print(resData)
                    print("responseData",responseData.result)
                    switch responseData.result {
                    case .Success:
                        let swiftyJsonVar = JSON(responseData.result.value!)
                        let resData = swiftyJsonVar["ResponseCode"].intValue
                            print("val",swiftyJsonVar["ResponseCode"])
                        if(resData == 1) {
                            let childViewController = self.storyboard?.instantiateViewControllerWithIdentifier("follow_friends") as! FirstFollowViewController
                  //          childViewController.reg_id = reg_id

                            
                            self.presentViewController(childViewController, animated: true, completion: nil)
                        }
                        else if(resData == 2) {
                            
                            let alert = UIAlertController(title: "Update Failed!", message:"Please try again", preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                                // PERFORM ACTION
                                })
                            self.presentViewController(alert, animated: true){}
                            
                        }
                        
                        
                    case .Failure(let error):
                        
                        let alert = UIAlertController(title: "No internet connection", message:"Check your internet connection and try again.", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                            // PERFORM ACTION
                            })
                        self.presentViewController(alert, animated: true){}
                        print(error)
                    }
                    
                } //END OF ALAMOFIRE
            }
            else {
                
                let alert = UIAlertController(title: "Sign Up Failed!", message:"You can use only smaller case alphabets,numbers and '_'.Char limit:5-15", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                    // PERFORM ACTION
                    })
                self.presentViewController(alert, animated: true){}
                //print("You can use only smaller case alphabets,numbers and '_'.Char limit:5-15 ")
            }
            
        }
        
        
    }
    
    func checkTextSufficientComplexity(var text : String) -> Bool{
        
        
        let smallLetterRegEx  = ".*[a-z]+.*"
        var texttest = NSPredicate(format:"SELF MATCHES %@", smallLetterRegEx)
        var smallresult = texttest.evaluateWithObject(text)
        print("\(smallresult)")
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        var texttest3 = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        var capitalresult = texttest3.evaluateWithObject(text)
        print("\(capitalresult)")
        
        let numberRegEx  = ".*[0-9]+.*"
        var texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        var numberresult = texttest1.evaluateWithObject(text)
        print("\(numberresult)")
        
        
        let specialCharacterRegEx  = ".*[_]+.*"
        var texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        
        var specialresult = texttest2.evaluateWithObject(text)
        print("\(specialresult)")

        let noSpecialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        var texttest4 = NSPredicate(format:"SELF MATCHES %@", noSpecialCharacterRegEx)
        
        var noSpecialresult = texttest4.evaluateWithObject(text)
        print("\(noSpecialresult)")

        let result = (smallresult || specialresult || numberresult) && (!noSpecialresult) && (!capitalresult)
        return result
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
    
    func maleAction(sender:UIButton) {
        print("maleAction")
        femaleBtn.transform = CGAffineTransformMakeScale(1,1)
        UIButton.setAnimationDuration(0.6)
        sender.transform = CGAffineTransformMakeScale(1.5,1.5)
        user_gender = "male"
        
    }
    func femaleAction(sender:UIButton) {
        print("femaleAction")
        maleBtn.transform = CGAffineTransformMakeScale(1,1)
        UIButton.setAnimationDuration(0.6)
        sender.transform = CGAffineTransformMakeScale(1.5,1.5)
        user_gender = "female"
        
    }
    
    
}

