//
//  VideoPlay.swift
//  Testify
//
//  Created by Pulkit Gambhir on 1/17/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import UIKit
import MediaPlayer
import Player

class SampleVideoController: UIViewController, PlayerDelegate {
    
    var player: Player!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     //   let bounds = UIScreen.mainScreen().bounds
     //   let width = bounds.size.width
       // let height = bounds.size.height
        
        let videoUrl:NSURL = NSURL(string: "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v")!
        
        
        self.player = Player()
        self.player.delegate = self
        self.player.view.frame = self.view.bounds
        
        self.addChildViewController(self.player)
        self.view.addSubview(self.player.view)
        self.player.didMoveToParentViewController(self)
        
        self.player.setUrl(videoUrl)
        
        self.player.playbackLoops = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
       // moviePlayer.controlStyle = MPMovieControlStyle.Embedded
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.player.playFromBeginning()
    }
    
    // MARK: UIGestureRecognizer
    
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