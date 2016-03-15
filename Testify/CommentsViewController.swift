//
//  CommentsViewController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 3/8/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Haneke


class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var video_id: Int?
    var idArr = [String]()
    var fNameArr = [String]()
    var lNameArr = [String]()
    var imgArr = [String]()
    var cmntArr = [String]()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addCmnt: UITextField!
    @IBOutlet var sendBtn: UIButton!
    
    
    var config = configUrl()
    var url : String?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        

    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("vid_id",video_id)
        navigationItem.title = "Comments"
        url = config.url + "new_app_service.php"
        print(url! + "url")
        addCmnt.delegate = self
        
        listAllComments()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        sendBtn.addTarget(self, action: "sendAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
    }
    

    func sendAction(sender: UIButton) {
        if (addCmnt.text! != "") {
        let param = ["do": "comment", "video_id": video_id!, "user_id": "3", "comment" : addCmnt.text!]   //live params
        Alamofire.request(.POST, url!, parameters: param as? [String : AnyObject]).responseJSON { (responseData) -> Void in
            
            
            switch responseData.result {
            case .Success:
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                print("jsonResponse" ,swiftyJsonVar);
                let resData = swiftyJsonVar["ResponseCode"].stringValue

                //print(resData[0]["phone"])
                if(Int(resData)! == 1) {
                    print("success")
                    
                    self.reset()
                    
                }
                else if(Int(resData)! == 2) {
                    
                    let alert = UIAlertController(title: "Failed!", message:"Some error occurred. Please try again.", preferredStyle: .Alert)
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

        addCmnt.text = ""
        view.window?.endEditing(true)
            
        
        print("kbc ",addCmnt.text)

        }
        
    }
    func reset() {
        print("haha")
        
        
        self.view.setNeedsDisplay()
        
        idArr.removeAll()
        fNameArr.removeAll()
        lNameArr.removeAll()
        imgArr.removeAll()
        cmntArr.removeAll()
        
        listAllComments()
    }
    
    func listAllComments() {
        let param = ["do": "Comment_list", "video_id": video_id!]   //live params
        // let param = ["do": "AllVideos", "user_id": "1", "id": "0","status": "up"]    //testing params
        Alamofire.request(.POST, url!, parameters: param as? [String : AnyObject]).responseJSON { (responseData) -> Void in
            
            
            switch responseData.result {
            case .Success:
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                print("jsonResponse home" ,swiftyJsonVar);
                
                
                for (key,subJson):(String, SwiftyJSON.JSON) in swiftyJsonVar["Comments"] {
                    //Do something you want
                    
                    if let vidData = subJson["user_id"].string {
                        self.idArr.append(vidData)
                        
                    }
                    if let vidData = subJson["first_name"].string {
                        self.fNameArr.append(vidData)
                        
                    }
                    if let vidData = subJson["last_name"].string {
                        self.lNameArr.append(vidData)
                        
                    }
                    if let vidData = subJson["imagepath"].string {
                        self.imgArr.append(vidData)
                        
                    }
                    if let vidData = subJson["comment"].string {
                        self.cmntArr.append(vidData)
                        
                    }
                    
                }
                
                
                self.tableView.reloadData()
                
            case .Failure(let error):
                
                let alert = UIAlertController(title: "No internet connection", message:"Check your internet connection and try again.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                    // PERFORM ACTION
                    })
                self.presentViewController(alert, animated: true){}
                print(error)
            }
            
        }
        tableView.reloadData()
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fNameArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cmntsCell", forIndexPath: indexPath) as! CommentsViewCell

        // Circular image of person
        let img: NSURL = NSURL(string: imgArr[indexPath.row])!
        
        // linkImg.image = UIImage(named: "placeholder.png")
        
        cell.userImg.layer.borderWidth = 1
        cell.userImg.layer.masksToBounds = true
        cell.userImg.layer.borderColor = UIColor.blackColor().CGColor
        cell.userImg.layer.cornerRadius = cell.userImg.frame.height/2
        cell.userImg.clipsToBounds = true
        
        cell.userImg.hnk_setImageFromURL(img)
        
        cell.userName.text = fNameArr[indexPath.row] + " " + lNameArr[indexPath.row]
        
        cell.userComment.text = cmntArr[indexPath.row]
        
        return cell
        
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    
}