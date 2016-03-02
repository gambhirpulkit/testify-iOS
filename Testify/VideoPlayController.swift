//
//  VideoPlayController.swift
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
import Player



class VideoPlayController: UIViewController, PlayerDelegate  {
    
    @IBOutlet var userImg: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var vidPlayView: UIImageView!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var cmntBtn: UIButton!
    @IBOutlet var shareBtn: UIButton!
    @IBOutlet var likeText: UIButton!
    @IBOutlet var cmntText: UIButton!
    @IBOutlet var shareText: UIButton!
    
    @IBOutlet var scrollView: UIScrollView!
    
  //  @IBOutlet var playBtn: UIButton!
    let playBtn = UIButton()
    
    var vidName = String()
    var thumbArr = String()
    var userThumb = String()
    var userFname = String()
    var userLname = String()
    var vidViews = String()
    var timestamp = String()
    var likeCount = String()
    var cmntCount = String()
    var shareCount = String()
    var sentiment = String()
    var vidStr = String()
    
    var player: Player!
    
    override func viewDidLoad() {
    super.viewDidLoad()
         print("vidName",vidName)
        let thumbImg: NSURL = NSURL(string: userThumb)!
        
       // playBtn.imageEdgeInsets = UIEdgeInsetsMake(25,25,25,25)
        playBtn.center = CGPointMake(vidPlayView.frame.size.width  / 2,
            vidPlayView.frame.size.height / 2)
        playBtn.frame = CGRectMake(0, 0, 300, 300)
       // playBtn.setTitle("test", forState: UIControlState.Normal)
        playBtn.setImage(UIImage(named: "playBtn"), forState: UIControlState.Normal)
        playBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)

      //  playBtn.contentHorizontalAlignment
        
        userImg.layer.borderWidth = 1
        userImg.layer.masksToBounds = true
        userImg.layer.borderColor = UIColor.blackColor().CGColor
        userImg.layer.cornerRadius = userImg.frame.height/2
        userImg.clipsToBounds = true
        
        userImg.hnk_setImageFromURL(thumbImg)
        
        userName.text = userFname
        
        
        let vidImg: NSURL = NSURL(string: thumbArr)!
        
        vidPlayView.hnk_setImageFromURL(vidImg)
        
        userName.text = userFname
        
        
        
        playBtn.addTarget(self, action: "playVideo:", forControlEvents: .TouchUpInside)
        
        print("likeCount",likeCount)
        likeText.setTitle(likeCount, forState: UIControlState.Normal)
        cmntText.setTitle(cmntCount, forState: UIControlState.Normal)
        shareText.setTitle(shareCount, forState: UIControlState.Normal)
        
        likeBtn.addTarget(self, action: "likeBtn:", forControlEvents: .TouchUpInside)
        

        self.vidPlayView.addSubview(playBtn)
        
    }
    
    func playVideo(sender: UIButton) {
        
        playBtn.hidden = true
        
        
        self.player = Player()
        self.player.delegate = self
        self.player.view.frame = self.vidPlayView.bounds
        
        self.addChildViewController(self.player)
        self.vidPlayView.addSubview(self.player.view)
        self.player.didMoveToParentViewController(self)
        
        let vidUrl: NSURL = NSURL(string: vidStr)!
        print("vidUrl",vidUrl)
        self.player.setUrl(vidUrl)
        
        self.player.playbackLoops = true
        
        self.vidPlayView.userInteractionEnabled = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.player.playFromBeginning()
    }
    
    func handleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.Stopped.rawValue:
            self.player.playFromBeginning()
        case PlaybackState.Paused.rawValue:
            self.player.playFromCurrentTime()
        case PlaybackState.Playing.rawValue:
            self.player.pause()
        case PlaybackState.Failed.rawValue:
            self.player.pause()
        default:
            self.player.pause()
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
    
    
    
}
