//
//  ExploreVideosController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 2/2/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import Haneke

class ExploreVideosController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var config = configUrl()
    var url : String?
    
    var vidName = [String]()
    var thumbArr = [String]()
    var userThumb = [String]()
    var userFname = [String]()
    var userLname = [String]()
    var vidViews = [String]()
    var timestamp = [String]()
    var likeCount = [String]()
    var cmntCount = [String]()
    var shareCount = [String]()
    var sentiment = [String]()
    var vidStr = [String]()

    var imgArr = [UIImage]()
    @IBOutlet var exploreView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   url = config.url + "app_services_p.php"                       // live url
        url = "http://testifyapp.org/Scribzoo/" + "app_services_p.php"   // testing url
        
        exploreView.backgroundColor = UIColor.whiteColor()
        
        let param = ["do": "AllVideos_main", "id": "150"]
    //    feedsTableView.allowsSelection = false
        
        
        Alamofire.request(.POST, url!, parameters: param).responseJSON { (responseData) -> Void in
            
            switch responseData.result {
            case .Success:
                
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                print("jsonResponse" ,swiftyJsonVar);
                let resData = swiftyJsonVar["ResponseCode"].stringValue
                
                //print(resData[0]["phone"])
                if(Int(resData)! == 1) {
                    
                    for (key,subJson):(String, SwiftyJSON.JSON) in swiftyJsonVar["Videos"] {
                        //Do something you want
                        if let text = subJson["story"].string {
                            self.vidName.append(text)
                            print("text",self.vidName[Int(key)!])
                        }
                        if let thumbUrl = subJson["thumb_path"].string {
                            self.thumbArr.append(thumbUrl)
                            print("text",self.thumbArr[Int(key)!])
                        }
                        if let vidData = subJson["imagepath"].string {
                            self.userThumb.append(vidData)
                            print("text",self.userThumb[Int(key)!])
                        }
                        if let vidData = subJson["user_first_name"].string {
                            self.userFname.append(vidData)
                            print("text",self.userFname[Int(key)!])
                        }
                        if let vidData = subJson["user_last_name"].string {
                            self.userLname.append(vidData)
                            print("text",self.userLname[Int(key)!])
                        }
                        if let vidData = subJson["view"].string {
                            self.vidViews.append(vidData)
                            print("text",self.vidViews[Int(key)!])
                        }
                        if let vidData = subJson["time"].string {
                            self.timestamp.append(vidData)
                            print("text",self.timestamp[Int(key)!])
                        }
                        if let vidData = subJson["like_count"].string {
                            self.likeCount.append(vidData)
                            print("text",self.likeCount[Int(key)!])
                        }
                        if let vidData = subJson["like_count"].string {
                            self.likeCount.append(vidData)
                            print("text",self.likeCount[Int(key)!])
                        }
                        if let vidData = subJson["comment_count"].string {
                            self.cmntCount.append(vidData)
                            print("text",self.cmntCount[Int(key)!])
                        }
                        if let vidData = subJson["share_count"].string {
                            self.shareCount.append(vidData)
                            print("text",self.shareCount[Int(key)!])
                        }
                        if let vidData = subJson["sentiment"].string {
                            self.sentiment.append(vidData)
                            print("text",self.sentiment[Int(key)!])
                        }
                        if let vidData = subJson["video_path"].string {
                            self.vidStr.append(vidData)
                            print("text",self.vidStr[Int(key)!])
                        }
                        
                    }
                    
                    
                    self.exploreView.reloadData()
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
        
        // Attach datasource and delegate
        self.exploreView.dataSource  = self
        self.exploreView.delegate = self
        
        //Layout setup
    //    setupCollectionView()
        
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vidName.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("exploreCell", forIndexPath: indexPath) as! ExploreVideosCell
        
        let collectionViewWidth = self.exploreView.bounds.size.width/3
        let collectionViewHeight = self.exploreView.bounds.size.width/3
        cell.frame.size.width = collectionViewWidth
        cell.frame.size.height = collectionViewHeight
       // cell.locationLabel.frame.size.width = collectionViewWidth
        
        let thumbImg: NSURL = NSURL(string: thumbArr[indexPath.row])!
        
        cell.vidShortName.text = vidName[indexPath.row]
        cell.vidThumbImg.hnk_setImageFromURL(thumbImg)
        
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionViewWidth = self.exploreView.bounds.size.width/3
        let collectionViewHeight = self.exploreView.bounds.size.width/3

        return CGSizeMake(collectionViewWidth, collectionViewHeight)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            let cell = sender as! UICollectionViewCell
            
            var vc = segue.destinationViewController as! VideoPlayController
            var myIndexPath : NSIndexPath = self.exploreView.indexPathForCell(cell)!
            let row = myIndexPath.row
            
            vc.vidName = vidName[row]
            vc.thumbArr = thumbArr[row]
            vc.userThumb = userThumb[row]
            vc.userFname = userFname[row]
            vc.userLname = userLname[row]
            vc.vidViews = vidViews[row]
            vc.timestamp = timestamp[row]
            vc.likeCount = likeCount[row]
            vc.cmntCount = cmntCount[row]
            vc.shareCount = shareCount[row]
            vc.sentiment = sentiment[row]
            vc.vidStr = vidStr[row]
            
           // print("segue data",vidName[row])
        }
    }
    


    

    
    
}