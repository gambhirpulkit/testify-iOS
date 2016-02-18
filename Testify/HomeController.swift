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
import Player


class HomeController: UIViewController, UITableViewDelegate,UITableViewDataSource, PlayerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var idArr = [String]()
    var fNameArr = [String]()
    var lNameArr = [String]()
    var imgArr = [String]()
    var thumbImgArr = [String]()
    var likesArr = [String]()
    var cmntArr = [String]()
    var shareArr = [String]()
    var vidArr = [String]()
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        tableView.allowsSelection = false
        
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
        let param = ["do": "AllVideos", "user_id": "1", "id": "0","status": "up"]
        
        Alamofire.request(.POST, url!, parameters: param).responseJSON { (responseData) -> Void in
            
            
            switch responseData.result {
            case .Success:
                let swiftyJsonVar = JSON(responseData.result.value!)
                
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
                    if let likeCount = subJson["like_count"].string {
                        self.likesArr.append(likeCount)
                        
                    }
                    if let cmntCount = subJson["comment_count"].string {
                        self.cmntArr.append(cmntCount)
                        
                    }
                    if let shareCount = subJson["share_count"].string {
                        self.shareArr.append(shareCount)
                        
                    }
                    if let vidPath = subJson["video_path"].string {
                        self.vidArr.append(vidPath)
                        
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
        let cell : HomeTableViewCell = tableView.dequeueReusableCellWithIdentifier("homeCell") as! HomeTableViewCell
        
        
        
        //cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        if let linkLabel = cell.viewWithTag(1) as? UILabel {
            linkLabel.text = fNameArr[indexPath.row] + " " + lNameArr[indexPath.row]
        }
       // if let linkLabel = cell.viewWithTag(4) as? UILabel {
       //     linkLabel.text = lNameArr[indexPath.row]
       // }
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

        cell.thumbImg.hnk_setImageFromURL(thumbImg)
/*        if let vidBtn = cell.viewWithTag(8) as? UIButton {
            
            
            vidBtn.addTarget(self, action: "connectedAction:", forControlEvents: .TouchUpInside)
            vidBtn.tag = indexPath.row
            
            
            print(indexPath.row)
            
        }
*/
        //print(cell)
        
        cell.vidBtn.addTarget(self, action: "connectedAction:", forControlEvents: .TouchUpInside)
        cell.vidBtn.tag = indexPath.row
        

        

        
        if let likeCount = cell.viewWithTag(5) as? UIButton {
            //linkLabel.text = lNameArr[indexPath.row]
            likeCount.setTitle(likesArr[indexPath.row] + " Likes", forState: UIControlState.Normal)
        }
        if let cmntCount = cell.viewWithTag(6) as? UIButton {
            //linkLabel.text = lNameArr[indexPath.row]
            cmntCount.setTitle(cmntArr[indexPath.row] + " Comments", forState: UIControlState.Normal)
        }
        if let shareCount = cell.viewWithTag(7) as? UIButton {
            //linkLabel.text = lNameArr[indexPath.row]
            shareCount.setTitle(shareArr[indexPath.row] + " Share", forState: UIControlState.Normal)
        }
        
        
        
        return cell
    }
    
    
    func connectedAction(sender : UIButton) {
        //let btnsendtag:UIButton = sender
        //print(sender.tag)
        //let cell = sender.superview!.superview as! UITableViewCell
        //let cellIndexPath = self.tableView.indexPathForCell(cell)
       // print(cellIndexPath)
        print(sender.tag)
        let g : NSIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let t : HomeTableViewCell = self.tableView.cellForRowAtIndexPath(g) as! HomeTableViewCell
        
        //print(g)
        
        t.vidBtn.hidden = true
        
        var vidStr : String = ""
        vidStr = vidArr[g.row]
        print("vidStr",vidStr)
        //let videoUrl:NSURL = NSURL(string: vidStr)!
        let videoUrl:NSURL = NSURL(string: "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v")!
        
        
        t.player = Player()
        
        t.player.view.frame = t.thumbImg.bounds
        
        self.addChildViewController(t.player)
        t.thumbImg.addSubview(t.player.view)
        t.player.didMoveToParentViewController(self)
        
        t.player.setUrl(videoUrl)
        
        t.player.playbackLoops = true
        
        t.thumbImg.userInteractionEnabled = true
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        tapGestureRecognizer.numberOfTapsRequired = 1
        t.player.view.addGestureRecognizer(tapGestureRecognizer)
        t.thumbImg.tag = g.row
        //print(g.row)
        print(t.thumbImg.tag)
        t.player.playFromBeginning()
        // let buttonRow = sender.tag
        
        


        
    }
    
    func handleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        let playView = gestureRecognizer.view
        let mainCell = playView?.superview
        //let main = mainCell?.superview
        //let cell: HomeTableViewCell = main as! HomeTableViewCell
        //let indexPath = tableView.indexPathForCell(cell)
        
        let g : NSIndexPath = NSIndexPath(forRow: mainCell!.tag, inSection: 0)
        let t : HomeTableViewCell = self.tableView.cellForRowAtIndexPath(g) as! HomeTableViewCell
        
        
        //print()
        switch (t.player.playbackState.rawValue) {
        case PlaybackState.Stopped.rawValue:
            t.player.playFromBeginning()
        case PlaybackState.Paused.rawValue:
            t.player.playFromCurrentTime()
        case PlaybackState.Playing.rawValue:
            t.player.pause()
        case PlaybackState.Failed.rawValue:
            t.player.pause()
        default:
            t.player.pause()
        }

    }
    

    func playerReady(player: Player) {
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
    }
    
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

