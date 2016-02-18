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
import AssetsLibrary

class VideoViewController: UIViewController,PlayerDelegate, UITextFieldDelegate {
    
    var player: Player!
    var config = configUrl()
   // var config = configUrl()
    var insertVidUrl : String?
    

    
        var vidUrl: NSURL?
    @IBOutlet weak var playView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        insertVidUrl = config.url + "app_services_p.php"
        print("insertVidUrl",insertVidUrl)
        
        
        
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
        let urlString: String = vidUrl!.absoluteString
        print("urlString",urlString)
        let testVar = ALAssetsLibrary()
        var assetUrl: NSURL?
        var assetRep: ALAssetRepresentation?
    
        testVar.assetForURL(vidUrl, resultBlock: {
            (asset: ALAsset!) in
            if asset != nil {
                assetRep = asset.defaultRepresentation()
                 assetUrl = assetRep!.url()
                    print("assetRep",assetUrl)
            }
            }, failureBlock: {
                (error: NSError!) in
                
                NSLog("Error!")
            }
        )
        
       // let testUrl: ALAssetsLibraryWriteVideoCompletionBlock?
/*         
       testVar!.writeVideoAtPathToSavedPhotosAlbum(vidUrl!, completionBlock: {(url: NSURL!, error: NSError!)  in
            print("URL %@");
            if error != nil{
            }
        })
*/
        
        
        /* Extract url from localvideo */
        let components = NSURLComponents(URL: self.vidUrl!, resolvingAgainstBaseURL: false)
        let queryItems = components!.queryItems!
        
        let id = queryItems.filter({$0.name == "id"}).first?.value
        let ext = queryItems.filter({$0.name == "ext"}).first?.value
        let vidFileName = id! + "." + ext!
        let thumbFileName = id! + ".png"
        let vidUrlName = config.url + "uploads/" + vidFileName
        let thumbUrlName = config.url + "uploads/" + thumbFileName
        
        let URL = config.url + "fileUpload.php"
        
        print(vidDescField.text)
        print(tagUsersField.text)
        
        print("assetUrl",assetUrl)
        
        let location = NSString(string:urlString).stringByExpandingTildeInPath
        
        print("fileContent",location)
        let data = (location as NSString).dataUsingEncoding(NSUTF32StringEncoding, allowLossyConversion: false)
        

        
        let thumbImg : UIImage = previewImageForLocalVideo(vidUrl!)!
        print("thumbImg",thumbImg)
        let thumbData = UIImageJPEGRepresentation(thumbImg, 0.5)
        //print("thumbData",thumbData)
        
        let optData:NSData? = data
        
        print("optData",optData)
        
        Alamofire.upload(.POST, URL, multipartFormData: {
            multipartFormData in


            if let vidData = optData {
                print("vidData",vidData)

                
               // print("id val", id!)
               // print("ext val",ext!)

                
                
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
        
        Alamofire.upload(.POST, URL, multipartFormData: {
            multipartFormData in

            if let imgData = thumbData {
                //print("vidData",vidData)

                
                // print("id val", id!)
                // print("ext val",ext!)
                
                
                
                print("queryItems",thumbFileName)
                
                multipartFormData.appendBodyPart(data: imgData, name: "image", fileName: thumbFileName, mimeType: "image/png")
                
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
       // print("")
        let param = ["do": "InsertVideos", "user_id" : 1, "story": vidDescField.text!, "sentiment" : "1","share_user_id" : 1, "video_path": vidUrlName, "thumb_path": thumbUrlName]
  
        Alamofire.request(.POST, insertVidUrl!, parameters: param as? [String : AnyObject]).responseJSON { (responseData) -> Void in
            let swiftyJsonVar = JSON(responseData.result.value!)
            
            print("jsonResponse" ,swiftyJsonVar);
            let resData = swiftyJsonVar["ResponseCode"].stringValue
            //print(resData[0]["phone"])
            if(Int(resData)! == 1) {

                
            }
            else if(Int(resData)! == 2) {
                
                let alert = UIAlertController(title: "Video upload Failed!", message:"Please try again!", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                    // PERFORM ACTION
                    })
                self.presentViewController(alert, animated: true){}
                
            }
            
        }
        
        
       // print(fileURL)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

    }
    
    func previewImageForLocalVideo(url:NSURL) -> UIImage?
    {
        let asset = AVAsset(URL: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        //If possible - take not the first frame (it could be completely black or white on camara's videos)
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            return UIImage(CGImage: imageRef)
        }
        catch
        {
            //let error: NSError?
            print("Image generation failed with error ")
            return nil
        }
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