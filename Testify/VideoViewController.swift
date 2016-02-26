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
import AVFoundation
//import AVAsset

class VideoViewController: UIViewController,PlayerDelegate, UITextFieldDelegate {
    
    var player: Player!
    var config = configUrl()
   // var config = configUrl()
    var insertVidUrl : String?
    var assetData : NSData?

    @IBOutlet weak var trimVid: UIButton!
    @IBOutlet weak var happyBtn: UIButton!
    @IBOutlet weak var sadBtn: UIButton!
    @IBOutlet weak var editBar: UIView!
    @IBOutlet weak var textField: UITextField!
    var sentiment: Int?
    
        var vidUrl: NSURL?
    @IBOutlet weak var playView: UIView!
    
    var reg_id: Int?
    var prefs:NSUserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        insertVidUrl = config.url + "app_services_p.php"
        print("insertVidUrl",insertVidUrl)
        
        prefs = NSUserDefaults.standardUserDefaults()
        print("regId video view",prefs!.integerForKey("reg_id"))
        reg_id = prefs!.integerForKey("reg_id")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        
        func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
    }
    
    var keyboardStatus: Int = 0
    func keyboardWillShow(notification: NSNotification) {
        print("test",keyboardStatus)
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if(keyboardStatus == 0) {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        keyboardStatus = 1
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("test1",keyboardStatus)
        keyboardStatus = 0
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            self.view.frame.origin.y += keyboardSize.height
            
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
        vidDescField.attributedPlaceholder = NSAttributedString(string:"What would you call this video?",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        tagUsersField.attributedPlaceholder = NSAttributedString(string:"Tag users",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        
        print("vidUrl",vidUrl)
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
        self.playView.addSubview(self.editBar)
                        print("check bc")
        self.vidDetails.addSubview(self.doneBtn)
        self.vidDetails.addSubview(self.cancelBtn)
        
        self.vidDetails.addSubview(self.vidDescField)
        self.vidDetails.addSubview(self.tagUsersField)
        print("ab bc")
        self.happyBtn.alpha = 1.0
        self.sadBtn.alpha = 1.0
        self.vidDetails.addSubview(self.happyBtn)
        self.vidDetails.addSubview(self.sadBtn)
        self.tagUsersField.delegate = self
        self.vidDescField.delegate = self

        self.doneBtn.addTarget(self, action: "goNext:", forControlEvents: UIControlEvents.TouchUpInside)
        self.cancelBtn.addTarget(self, action: "goHome:", forControlEvents: UIControlEvents.TouchUpInside)
       // self.doneBtn.tag = 1
        self.happyBtn.addTarget(self, action: "happyAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.sadBtn.addTarget(self, action: "sadAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.editBar.addSubview(self.trimVid)
        self.trimVid.addTarget(self, action: "trimVidAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
    }
    
    func trimVidAction(sender:UIButton) {
        var alert = UIAlertController(title: "Alert Title", message: "Alert Message", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            print("User click Ok button")
            print(self.textField.text)
        }))
        self.presentViewController(alert, animated: true, completion: {
            print("completion block")
        })

        
    }
    func configurationTextField(textField: UITextField!)
    {
        print("configurat hire the TextField")
        
        if let tField = textField {
            //self.textField.frame = CGRectMake(50, 70, 200, 30)
            self.textField = textField!        //Save reference to the UITextField
            self.textField.text = "Hello world"
        }
    }
    
    
    func handleCancel(alertView: UIAlertAction!)
    {
        print("User click Cancel button")
        print(self.textField.text)
    }

    
    
    func happyAction(sender:UIButton) {
        print("happyAction")
        sadBtn.transform = CGAffineTransformMakeScale(1,1)
        UIButton.setAnimationDuration(0.6)
        sender.transform = CGAffineTransformMakeScale(1.5,1.5)
        sentiment = 1
        
    }
    func sadAction(sender:UIButton) {
        print("sadAction")
        happyBtn.transform = CGAffineTransformMakeScale(1,1)
        UIButton.setAnimationDuration(0.6)
        sender.transform = CGAffineTransformMakeScale(1.5,1.5)
        sentiment = 0
        
    }
    
    
    
    func goHome(sender:UIButton) {
        let vc: TabBarController? = self.storyboard?.instantiateViewControllerWithIdentifier("afterUpload") as? TabBarController
        self.presentViewController(vc!, animated: true, completion: nil)

    }
    
    
    func goNext(sender:UIButton) {
        print("bc")
       // print(sender.tag)
        print(vidUrl!)
        let urlString: String = vidUrl!.absoluteString
        print("urlString",urlString)

       // let testUrl: ALAssetsLibraryWriteVideoCompletionBlock?
/*         
       testVar!.writeVideoAtPathToSavedPhotosAlbum(vidUrl!, completionBlock: {(url: NSURL!, error: NSError!)  in
            print("URL %@");
            if error != nil{
            }
        })
*/
        
        guard (sentiment == 0 || sentiment == 1 ) else {
            let alert = UIAlertController(title: "Enter all fields", message:"Please enter all the fields to proceed", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                // PERFORM ACTION
                })
            self.presentViewController(alert, animated: true){}
            return
        }

        
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
        

        
        let thumbImg : UIImage = previewImageForLocalVideo(vidUrl!)!
        print("thumbImg",thumbImg)
        let thumbData = UIImageJPEGRepresentation(thumbImg, 0.5)
        //print("thumbData",thumbData)
        
        /* video upload and conversion to NSData */
        let vidAsset = AVAsset(URL: vidUrl!)
        let clipVideoTrack = vidAsset.tracksWithMediaType(AVMediaTypeVideo).first! as AVAssetTrack
        
        let composition = AVMutableComposition()
        composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        let videoComposition = AVMutableVideoComposition()
        
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
        print("height",clipVideoTrack.naturalSize.width)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        let transform1: CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0)
        print("")
        let transform2 = CGAffineTransformRotate(transform1, CGFloat(M_PI_2))
        let finalTransform = transform2
        
        
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]

        
      
        let exportPath: NSString = NSTemporaryDirectory().stringByAppendingFormat("\(id!).mp4")
        print("exportPath",exportPath)
        let exportUrl: NSURL = NSURL.fileURLWithPath(exportPath as String)

        
        let vidExp :AVAssetExportSession = AVAssetExportSession(asset: vidAsset, presetName: AVAssetExportPresetHighestQuality)!
        vidExp.videoComposition = videoComposition
        vidExp.outputURL = exportUrl
        vidExp.outputFileType = AVFileTypeMPEG4 //AVFileTypeQuickTimeMovie
        vidExp.exportAsynchronouslyWithCompletionHandler({
        switch vidExp.status{
        case  AVAssetExportSessionStatus.Failed:
        print("failed \(vidExp.error)")
        case AVAssetExportSessionStatus.Cancelled:
        print("cancelled \(vidExp.error)")
        default:
        self.assetData = NSData(contentsOfURL: vidExp.outputURL!)
            
        /*  upload video */
        Alamofire.upload(
            .POST,
            URL,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: self.assetData!, name: "image", fileName: vidFileName, mimeType: "video/mp4")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                        print(totalBytesWritten)
                        print("totalBytesExpectedToWrite",totalBytesExpectedToWrite)
                        // This closure is NOT called on the main queue for performance
                        // reasons. To update your ui, dispatch to the main queue.
                        dispatch_async(dispatch_get_main_queue()) {
                            print("total length",self.assetData!.length)
                         
                        }
                        }
                        .responseJSON { response in
                            debugPrint(response)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
            )
            /* end upload video */
        // print("assetData",self.assetData)
        }
        })
        //multipartFormData.appendBodyPart(data: self.assetData!, name: "image", fileName: vidFileName, mimeType: "video/mp4")
        print("exportURL",exportUrl.absoluteString)
        /* end video upload and conversion to NSData */

        //   print("assetData1",self.assetData)



        
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
        print("regId video view1",self.reg_id!)
        
        let param = ["do": "InsertVideos", "user_id" : self.reg_id!, "story": vidDescField.text!, "sentiment" : "\(sentiment)","share_user_id" : self.reg_id!, "video_path": vidUrlName, "thumb_path": thumbUrlName]
  
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
        let vc: TabBarController? = self.storyboard?.instantiateViewControllerWithIdentifier("afterUpload") as? TabBarController
        if let validVC: TabBarController = vc {
            self.presentViewController(validVC, animated: true, completion: nil)
/*            if let capturedImage = videoURL {
                validVC.vidUrl = capturedImage
                
            }
*/
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