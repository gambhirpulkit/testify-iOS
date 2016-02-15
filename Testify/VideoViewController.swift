//
//  ImageViewController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 2/3/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//
 
import UIKit
import MediaPlayer
import Player
import SwiftyJSON
import Alamofire

class VideoViewController: UIViewController,PlayerDelegate, UITextFieldDelegate {
    
    var player: Player!
    var config = configUrl()

    
        var vidUrl: NSURL?
    @IBOutlet weak var playView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        
       // self.doneBtn
        
        func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
    }

    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var vidDescField: UITextField!
    @IBOutlet weak var tagUsersField: UITextField!
    
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet var vidDetails: UIView!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("vidUrl",vidUrl);
        self.player = Player()
        self.player.delegate = self
        self.player.view.frame = self.playView.bounds
        
        self.addChildViewController(self.player)
        self.playView.addSubview(self.player.view)
        self.player.didMoveToParentViewController(self)
        
        self.player.setUrl(vidUrl!)
        
        self.player.playbackLoops = true

        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.player.playFromBeginning()
        
        //self.vidDetails.backgroundColor = UIColor(white: 1, alpha: 0.9)
        self.playView.addSubview(self.vidDetails)
                        print("check bc")
        self.vidDetails.addSubview(self.doneBtn)
        self.vidDetails.addSubview(self.cancelBtn)
        
        self.vidDetails.addSubview(self.vidDescField)
        self.vidDetails.addSubview(self.tagUsersField)
        print("ab bc")
        self.tagUsersField.delegate = self
        self.vidDescField.delegate = self

        
        self.doneBtn.addTarget(self, action: "goNext:", forControlEvents: UIControlEvents.TouchUpInside)
       // self.doneBtn.tag = 1
        
    }
    
    
    
    func goNext(sender:UIButton) {
        print("bc")
       // print(sender.tag)
        print(vidUrl!)
        let urlString = vidUrl!.absoluteString
        
        let URL = config.url + "fileUpload.php"
        
        print(vidDescField.text)
        print(tagUsersField.text)
        
        let location = NSString(string:urlString).stringByExpandingTildeInPath

        print("fileContent",location)
        let data = (location as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let optData:NSData? = data
        
        print("optData",optData)
        
        Alamofire.upload(.POST, URL, multipartFormData: {
            multipartFormData in


            if let vidData = optData {
                print("vidData",vidData)
                let components = NSURLComponents(URL: self.vidUrl!, resolvingAgainstBaseURL: false)
                let queryItems = components!.queryItems!
                
                let id = queryItems.filter({$0.name == "id"}).first?.value
                let ext = queryItems.filter({$0.name == "ext"}).first?.value
                
               // print("id val", id!)
               // print("ext val",ext!)
                
                let vidFileName = id! + "." + ext!
                
                
                print("queryItems",vidFileName)
                
                    multipartFormData.appendBodyPart(data: vidData, name: "image", fileName: vidFileName, mimeType: "video/mp4")
               
            }
            
            },    encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
        
       // print(fileURL)
    }


    
    
    // Keyboard hide on return pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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