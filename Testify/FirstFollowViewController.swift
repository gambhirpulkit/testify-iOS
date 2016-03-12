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

class FirstFollowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var followTable: UITableView!
    
    @IBOutlet var nextView: UIView!
    
    var idArr = [String]()
    
    
    var config = configUrl()
    var url : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        url = "http://testifyapp.org/Scribzoo/" + "new_v_api.php"
        print(url)
        
        
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
                         //   self.idArr.append(vidData)
                         //   print(self.idArr[Int(key)!])
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
            
        } //END OF ALAMOFIRE
        
      //  let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
      //  nextView.addGestureRecognizer(tapGesture)
        
    }
  /*
    func handleTap(sender: UITapGestureRecognizer) {
        print("yess")
    }
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("followCell") as! FirstFollowTableViewCell
        cell.userName.text = "haha"
        
        
        return cell
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
