//
//  NotificationFeedsController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 2/25/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import Haneke

class NotiFeedsController: UIViewController {
    
    var config = configUrl()
    var url : String?
    
    var notiText = [String]()
    var imageArr = [String]()
    var thumbArr = [String]()
    
    
    @IBOutlet var feedsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        url = config.url + "new_app_service.php"
        print(url! + "url")
        let param = ["do": "notifications", "user_id": "8"]
        feedsTableView.allowsSelection = false
        
        
        Alamofire.request(.POST, url!, parameters: param).responseJSON { (responseData) -> Void in
            
            switch responseData.result {
            case .Success:
            
            let swiftyJsonVar = JSON(responseData.result.value!)
            
            print("jsonResponse" ,swiftyJsonVar);
            let resData = swiftyJsonVar["ResponseCode"].stringValue

            //print(resData[0]["phone"])
            if(Int(resData)! == 1) {

                for (key,subJson):(String, SwiftyJSON.JSON) in swiftyJsonVar["data"] {
                    //Do something you want
                    if let text = subJson["text"].string {
                        self.notiText.append(text)
                        print("text",self.notiText[Int(key)!])
                    }
                    if let imagePath = subJson["imagepath"].string {
                        self.imageArr.append(imagePath)
                        print("imagePath",self.imageArr[Int(key)!])
                    
                    
                        if(!subJson["imagepath"]) {
                            
                            self.thumbArr.append(imagePath)
                        }
                        else {
                            self.thumbArr.append(subJson["imagepath"].string!)
                        }
                        
                        print("thumb_path",self.thumbArr[Int(key)!])
                    
                    }
                    
                }
                
                
             self.feedsTableView.reloadData()
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
        }  // end of Alamofire
        
        
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(notiText.count)
        return notiText.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : NotiFeedsTableViewCell = tableView.dequeueReusableCellWithIdentifier("notiCell") as! NotiFeedsTableViewCell
        
        cell.notiText.text = notiText[indexPath.row]
        
        let thumbImg: NSURL = NSURL(string: thumbArr[indexPath.row])!
       // let defThumbImg: NSURL = NSURL(string: imageArr[indexPath.row])!
        
      //  print("thumbImg",thumbImg)
        
        cell.notiUserImg.layer.borderWidth = 1
        cell.notiUserImg.layer.masksToBounds = true
        cell.notiUserImg.layer.borderColor = UIColor.blackColor().CGColor
        cell.notiUserImg.layer.cornerRadius = cell.notiUserImg.frame.height/2
        cell.notiUserImg.clipsToBounds = true
        
        cell.notiUserImg.hnk_setImageFromURL(thumbImg)
        //print("notiText",notiText)
        
        return cell
    }
}