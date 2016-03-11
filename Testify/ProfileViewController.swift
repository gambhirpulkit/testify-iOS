//
//  ProfileViewController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 3/10/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController {
    
    @IBOutlet var userImg: UIImageView!
    
    @IBOutlet var userDetails: UIView!
    
    @IBOutlet var logoutBtn: UIButton!
    
    @IBOutlet var followersBtn: UIButton!
    @IBOutlet var videosBtn: UIButton!
    @IBOutlet var followingBtn: UIButton!
    
    @IBOutlet var userNameGen: UILabel!
    @IBOutlet var aboutUser: UILabel!
    @IBOutlet var username: UILabel!
    
    var config = configUrl()
    var url : String?
    
    @IBOutlet var viewLayer: UIView!
    
    var reg_id: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var colors = [CGColor]()
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 1).CGColor)
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0).CGColor)
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 1).CGColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0).CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 54)

        
       viewLayer.layer.insertSublayer(gradient, atIndex: 0)

        
        url = config.url + "new_v_api.php"
        print(url! + "url")
        userImg.addSubview(logoutBtn)
        reg_id = prefs.integerForKey("reg_id")
        
        let param = ["do": "user_profile", "user_id": reg_id!]   //live params
        // let param = ["do": "AllVideos", "user_id": "1", "id": "0","status": "up"]    //testing params

        Alamofire.request(.POST, url!, parameters: param as! [String : AnyObject] ).responseJSON { (responseData) -> Void in
            
            print("check response",responseData.result)
            switch responseData.result {
            case .Success:
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                print("jsonResponse" ,swiftyJsonVar);
                let resData = swiftyJsonVar["ResponseCode"].stringValue
                
                //print(resData[0]["phone"])
                if(Int(resData)! == 1) {
                    
                let imgPath = swiftyJsonVar["user_details"]["imagepath"].stringValue
                let followersCount = swiftyJsonVar["user_details"]["followers"].stringValue
                let followingCount = swiftyJsonVar["user_details"]["follow"].stringValue
                let videosCount = swiftyJsonVar["user_details"]["post"].stringValue
                    
                let fName = swiftyJsonVar["user_details"]["first_name"].stringValue
                let lName = swiftyJsonVar["user_details"]["last_name"].stringValue
                let gender = swiftyJsonVar["user_details"]["gender"].stringValue
                let aboutUser = swiftyJsonVar["user_details"]["about_me"].stringValue
                let username = swiftyJsonVar["user_details"]["user_name"].stringValue
                    print("userName",username)
                self.userNameGen.text = fName + " " + lName + ", " + gender
               // self.aboutUser.text = aboutUser
                self.username.text = username
                    
                    if(aboutUser != "") {
                        self.aboutUser.text = aboutUser
                    }
                    
                    
                self.followersBtn.setTitle(followersCount, forState: UIControlState.Normal)
                self.followingBtn.setTitle(followingCount, forState: UIControlState.Normal)
                self.videosBtn.setTitle(videosCount, forState: UIControlState.Normal)
                    
                let imgUrl = NSURL(string: imgPath)
                    
                self.userImg.hnk_setImageFromURL(imgUrl!)
                    
             //   print("imagePath",imgPath)
                    

                }
                else if(Int(resData)! == 2) {
                    
                    let alert = UIAlertController(title: "Some error occurred!", message:"Error occurred", preferredStyle: .Alert)
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
        
        }
        
        logoutBtn.addTarget(self, action: "logoutAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func logoutAction(sender: UIButton) {
        
        print("logging out")
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        
    }
    
    
    
}
