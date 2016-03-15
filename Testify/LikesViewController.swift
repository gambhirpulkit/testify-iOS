//
//  LikesViewController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 3/8/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Haneke
import SwiftyJSON

class LikesViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
 
    var idArr = [String]()
    var fNameArr = [String]()
    var lNameArr = [String]()
    var imgArr = [String]()
    var video_id: Int?
    
    @IBOutlet var tableView: UITableView!
    
    
    
    var config = configUrl()
    var url : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("vid_id",video_id)
        navigationItem.title = "Likes"
        url = config.url + "new_app_service.php"
        print(url! + "url")
        let param = ["do": "like_users_list", "video_id": video_id!]   //live params
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
        return idArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("likesCell", forIndexPath: indexPath) as! LikesViewCell
        
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
        
        return cell 
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      //  ++vcCount
        navigationItem.title = "test"
    }
    
    
}
