//
//  FirstFollowViewController.swift
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

class FirstFollowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet var followTable: UITableView!
    
    @IBOutlet var nextView: UIView!
    
    var idArr = [String]()
    var nameArr = [String]()
    var imgArr = [String]()
    var aboutUserArr = [String]()
    
    var toIdArr = [String]() // Id of people to follow
    
    var config = configUrl()
    var url : String?
    var reg_id: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    url = "http://testifyapp.org/Scribzoo/" + "new_v_api.php"
        url = config.url + "new_v_api.php"
        print(url)
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        print("regId home",prefs.integerForKey("reg_id"))
        reg_id = prefs.integerForKey("reg_id")
        
        followTable.allowsSelection = false
        
        let param = ["do": "Most_Populer"]
        
        Alamofire.request(.POST, url!, parameters: param).responseJSON { (responseData) -> Void in
            
            //   let swiftyJsonVar = JSON(responseData.result.value!)
            
            //    print("jsonResponse" ,swiftyJsonVar);
            //   let resData = swiftyJsonVar["ResponseCode"].stringValue
            //   print(resData)
            print("responseData",responseData.result)
            switch responseData.result {
            case .Success:
                let swiftyJsonVar = JSON(responseData.result.value!)

                print("jsonResponse home" ,swiftyJsonVar);
                
                
                for (key,subJson):(String, SwiftyJSON.JSON) in swiftyJsonVar["most_populer"] {
                    //Do something you want
                    if let vidData = subJson["user_id"].string {
                        print("vidData",vidData)
                            self.idArr.append(vidData)
                         //   print(self.idArr[Int(key)!])
                    }
                    if let vidData = subJson["user_name"].string {
                        print("vidData",vidData)
                        self.nameArr.append(vidData)
                        //   print(self.idArr[Int(key)!])
                    }
                    if let vidData = subJson["user_image_path"].string {
                        print("vidData",vidData)
                        self.imgArr.append(vidData)
                        //   print(self.idArr[Int(key)!])
                    }
                    if let vidData = subJson["user_about_me"].string {
                        print("vidData",vidData)
                        self.aboutUserArr.append(vidData)
                        //   print(self.idArr[Int(key)!])
                    }
                    
                }
                
                self.followTable.reloadData()

                
                
            case .Failure(let error):
                
                let alert = UIAlertController(title: "No internet connection", message:"Check your internet connection and try again.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                    // PERFORM ACTION
                    })
                self.presentViewController(alert, animated: true){}
                print(error)
            }
            
        } //END OF ALAMOFIRE
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        nextView.addGestureRecognizer(tapGesture)
        
    }
  
    func handleTap(sender: UITapGestureRecognizer) {
        print("yess")
        let stringRepresentation = toIdArr.joinWithSeparator(",")
        print("comma",stringRepresentation)
        print("reg_idd",reg_id!)
        let param = ["do": "Follow_multiple_request","to_id": stringRepresentation,"from_id": reg_id!]
        Alamofire.request(.POST, url!, parameters: param as! [String : AnyObject]).responseString { (responseData) -> Void in
            
            //   let swiftyJsonVar = JSON(responseData.result.value!)
            
            //    print("jsonResponse" ,swiftyJsonVar);
            //   let resData = swiftyJsonVar["ResponseCode"].stringValue
            //   print(resData)
            print("responseData",responseData.result)
            switch responseData.result {
            case .Success:
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                print("jsonResponse home" ,swiftyJsonVar);
                
                let childViewController = self.storyboard?.instantiateViewControllerWithIdentifier("afterUpload") as! TabBarController

                
                self.presentViewController(childViewController, animated: true, completion: nil)
                
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("followCell") as! FirstFollowTableViewCell
        cell.userName.text = nameArr[indexPath.row]
        let img: NSURL = NSURL(string: imgArr[indexPath.row])!
        
    
            cell.userImage.layer.borderWidth = 1
            cell.userImage.layer.masksToBounds = true
            cell.userImage.layer.borderColor = UIColor.blackColor().CGColor
            cell.userImage.layer.cornerRadius = cell.userImage.frame.height/2
            cell.userImage.clipsToBounds = true
            
            cell.userImage.hnk_setImageFromURL(img)
            //print(imgArr[indexPath.row])
        
            cell.aboutUser.text = aboutUserArr[indexPath.row]

            cell.followBtn.addTarget(self, action: "followAction:", forControlEvents: UIControlEvents.TouchUpInside)
            //cell.followBtn.tag = Int(idArr[indexPath.row])!
            cell.followBtn.tag = indexPath.row
        
        return cell
    }
    
    func followAction(sender: UIButton) {
       // print("checkFollow",sender.tag)
        
        let g : NSIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        
        
        let t : FirstFollowTableViewCell = self.followTable.cellForRowAtIndexPath(g) as! FirstFollowTableViewCell
        
        let idToFollow = String(idArr[g.row])
        print("idToFollow",idToFollow)
        if toIdArr.contains(idToFollow) {
            if let index = toIdArr.indexOf(idToFollow) {
                toIdArr.removeAtIndex(index)
                
            }
            //toIdArr.remove(idToFollow)
        }
        else {
            
        toIdArr.append(idToFollow)
        }
        
        
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! FirstFollowHeaderCell
        headerCell.backgroundColor = UIColor.cyanColor()
        
        switch (section) {
        case 0:
            headerCell.headerLabel.text = "Follow atleast 5 people to continue";
            //return sectionHeaderView
        default:
            headerCell.headerLabel.text = "..";
        }
        
        return headerCell
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    
}
