//
//  HomeController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 1/14/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Haneke
import MediaPlayer

class HomeController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var idArr = [String]()
    var fNameArr = [String]()
    var lNameArr = [String]()
    var imgArr = [String]()
    var thumbImgArr = [String]()
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        print(prefs.integerForKey("ISLOGGEDIN"))
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            //self.usernameLabel.text = prefs.valueForKey("USERNAME") as? String
            //let appDomain = NSBundle.mainBundle().bundleIdentifier
            //NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
            //tableView.reloadData()
        }
    }
    
    var config = configUrl()
    var url : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        url = config.url + "app_services_p.php"
        print(url! + "url")
        let param = ["do": "AllVideos", "user_id": "159", "id": "0","status": "up"]
        
        Alamofire.request(.POST, url!, parameters: param).responseJSON { (responseData) -> Void in
            let swiftyJsonVar = JSON(responseData.result.value!)
            
            switch responseData.result {
            case .Success:
                
                
                print("jsonResponse" ,swiftyJsonVar);
                
                
                for (key,subJson):(String, SwiftyJSON.JSON) in swiftyJsonVar["Videos"] {
                    //Do something you want
                    if let vid_id = subJson["id"].string {
                        self.idArr.append(vid_id)
                        print(self.idArr[Int(key)!])
                    }
                    if let fName = subJson["first_name"].string {
                        self.fNameArr.append(fName)
                        
                    }
                    if let lName = subJson["last_name"].string {
                        self.lNameArr.append(lName)
                        
                    }
                    if let imgPath = subJson["imagepath"].string {
                        self.imgArr.append(imgPath)
                        
                    }
                    if let thumbImg = subJson["thumb_path"].string {
                        self.thumbImgArr.append(thumbImg)
                        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("homeCell", forIndexPath: indexPath) 
        
        //cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        if let linkLabel = cell.viewWithTag(1) as? UILabel {
            linkLabel.text = fNameArr[indexPath.row]
        }
        if let linkLabel = cell.viewWithTag(4) as? UILabel {
            linkLabel.text = lNameArr[indexPath.row]
        }
        // Circular image of person
        let img: NSURL = NSURL(string: imgArr[indexPath.row])!
        if let linkImg = cell.viewWithTag(2) as? UIImageView {
           // linkImg.image = UIImage(named: "placeholder.png")
            
            linkImg.layer.borderWidth = 1
            linkImg.layer.masksToBounds = true
            linkImg.layer.borderColor = UIColor.blackColor().CGColor
            linkImg.layer.cornerRadius = linkImg.frame.height/2
            linkImg.clipsToBounds = true
        
            linkImg.hnk_setImageFromURL(img)
            //print(imgArr[indexPath.row])
        }
        let thumbImg: NSURL = NSURL(string: thumbImgArr[indexPath.row])!
        if let thumbImage = cell.viewWithTag(3) as? UIImageView {
            thumbImage.hnk_setImageFromURL(thumbImg)
        }
        
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

