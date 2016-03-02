//
//  VideoRecordController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 1/31/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//


import UIKit
import CameraManager
import SwiftyJSON
import Alamofire
import AVFoundation

class VideoRecordController: UIViewController {
    
    // MARK: - Constants
    
    let cameraManager = CameraManager()
    var timer = NSTimer()
    var counter = 0
    // MARK: - @IBOutlets
    
    @IBOutlet weak var camTimer: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var flashModeButton: UIButton!
    
    @IBOutlet weak var askForPermissionsButton: UIButton!
    @IBOutlet weak var askForPermissionsLabel: UILabel!
    
    
    
    
    // MARK: - UIViewController
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraManager.showAccessPermissionPopupAutomatically = false
        
        askForPermissionsButton.hidden = true
        askForPermissionsLabel.hidden = true
        
        
        cameraManager.cameraOutputQuality = .High
        
        let currentCameraState = cameraManager.currentCameraStatus()
        
        if currentCameraState == .NotDetermined {
            askForPermissionsButton.hidden = false
            askForPermissionsLabel.hidden = false
        } else if (currentCameraState == .Ready) {
            addCameraToView()
        }
        if !cameraManager.hasFlash {
            flashModeButton.enabled = false
            flashModeButton.setTitle("No flash", forState: UIControlState.Normal)
        }
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            print("vidDuration",self.cameraManager.recordedDuration)
            let dTotalSeconds : Double = CMTimeGetSeconds(self.cameraManager.recordedDuration)
            print(dTotalSeconds)
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.hidden = true
        cameraManager.resumeCaptureSession()
        

        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
    }
    
    
    // MARK: - ViewController
    
    private func addCameraToView()
    {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.VideoWithMic)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in  }))
            
            self?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - @IBActions
    
    @IBAction func changeFlashMode(sender: UIButton)
    {
        switch (cameraManager.changeFlashMode()) {
        case .Off:
            sender.setTitle("Flash Off", forState: UIControlState.Normal)
        case .On:
            sender.setTitle("Flash On", forState: UIControlState.Normal)
        case .Auto:
            sender.setTitle("Flash Auto", forState: UIControlState.Normal)
        }
    }
    @IBAction func closeCamBtn(sender: AnyObject) {
        let vc: TabBarController? = self.storyboard?.instantiateViewControllerWithIdentifier("afterUpload") as? TabBarController
        self.presentViewController(vc!, animated: true, completion: nil)

        
        
    }
    
    @IBAction func recordButtonTapped(sender: UIButton) {
        

        
        sender.selected = !sender.selected
        sender.setTitle(" ", forState: UIControlState.Selected)
        //sender.backgroundColor = sender.selected ? UIColor.redColor() : UIColor.greenColor()
        if sender.selected {
            sender.backgroundColor = UIColor.redColor()
            cameraManager.startRecordingVideo()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "timerAction", userInfo: nil, repeats: true)


        } else {
            
            
            
            cameraManager.stopRecordingVideo({ (videoURL, error) -> Void in
                if let errorOccured = error {
                    self.cameraManager.showErrorBlock(erTitle: "Error occurred", erMessage: errorOccured.localizedDescription)
                }
                else {
                    //self.cameraManager.writeFilesToPhoneLibrary = true
                    print("timer Duration",self.cameraManager.recordedDuration)
                    let videoDurationSeconds: Double = CMTimeGetSeconds(self.cameraManager.recordedDuration)
                    print("videoDurationSeconds",videoDurationSeconds)
                    if(videoDurationSeconds < 30) {
                        
                    print("videoURL",videoURL)
                        
                        self.sendExportVideo(videoURL!)


                    }
                    else {

                        let refreshAlert = UIAlertController(title: "Hola", message: "Video length is longer than 30s", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "Trim video", style: .Default, handler: { (action: UIAlertAction!) in
                            print("Handle Ok logic here")
                            self.sendExportVideo(videoURL!)
                        }))
                        
                        refreshAlert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (action: UIAlertAction!) in
                            print("Handle Cancel Logic here")
                        }))
                        
                        self.presentViewController(refreshAlert, animated: true, completion: nil)
                       print("video longer than 30s")
                        
                        
                    }
                }
            })
        }
        
    }
    func timerAction() {
        ++counter
        camTimer.text = "\(counter)"
    }
    
    func sendExportVideo(vidLink: NSURL) {
        let components = NSURLComponents(URL: vidLink, resolvingAgainstBaseURL: false)
        let queryItems = components!.queryItems!
        
        let id = queryItems.filter({$0.name == "id"}).first?.value
        
        
        /* video upload and conversion to NSData */
        let vidAsset = AVAsset(URL: vidLink)
        let clipVideoTrack = vidAsset.tracksWithMediaType(AVMediaTypeVideo).first! as AVAssetTrack
/*
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
        
*/
        
        let exportPath: NSString = NSTemporaryDirectory().stringByAppendingFormat("\(id!).mp4")
        print("exportPath",exportPath)
        let exportUrl: NSURL = NSURL.fileURLWithPath(exportPath as String)
        
        let startTime: CMTime = CMTimeMakeWithSeconds(0.0, 600)
        let duration: CMTime = CMTimeMakeWithSeconds(30.0, 600)
        let range: CMTimeRange = CMTimeRangeMake(startTime, duration)
        
        
        let vidExp :AVAssetExportSession = AVAssetExportSession(asset: vidAsset, presetName: AVAssetExportPresetHighestQuality)!
    //    vidExp.videoComposition = videoComposition
        vidExp.outputURL = exportUrl
        vidExp.outputFileType = AVFileTypeMPEG4 //AVFileTypeQuickTimeMovie
        vidExp.timeRange = range
        vidExp.exportAsynchronouslyWithCompletionHandler({
            switch vidExp.status{
            case  AVAssetExportSessionStatus.Failed:
                print("failed \(vidExp.error)")
            case AVAssetExportSessionStatus.Cancelled:
                print("cancelled \(vidExp.error)")
            default:
                // self.assetData = NSData(contentsOfURL: vidExp.outputURL!)
                
                /* end upload video */
                // print("assetData",self.assetData)
                
                let vc: VideoViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("ImageVC") as? VideoViewController
                if let validVC: VideoViewController = vc {
                   /*  if let capturedImage = vidLink {
                        validVC.vidUrl = capturedImage
                        // self.presentViewController(validVC, animated: true, completion: nil)
                    } */
                    validVC.vidUrl = vidLink
                    if let capturedVideo = vidExp.outputURL {
                        validVC.vidExpUrl = capturedVideo
                        //    self.presentViewController(validVC, animated: true, completion: nil)
                    }
                    self.presentViewController(validVC, animated: true, completion: nil)
                }
                
            }
        })
    }
    
    
    @IBAction func changeCameraDevice(sender: UIButton) {
        
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.Front ? CameraDevice.Back : CameraDevice.Front
        switch (cameraManager.cameraDevice) {
        case .Front:
            sender.setTitle("", forState: UIControlState.Normal)
        case .Back:
            sender.setTitle("", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func askForCameraPermissions(sender: UIButton) {
        
        cameraManager.askUserForCameraPermissions({ permissionGranted in
            self.askForPermissionsButton.hidden = true
            self.askForPermissionsLabel.hidden = true
            self.askForPermissionsButton.alpha = 0
            self.askForPermissionsLabel.alpha = 0
            if permissionGranted {
                self.addCameraToView()
            }
        })
    }
    /*
    @IBAction func changeCameraQuality(sender: UIButton) {
    
    switch (cameraManager.changeQualityMode()) {
    case .High:
    sender.setTitle("High", forState: UIControlState.Normal)
    case .Low:
    sender.setTitle("Low", forState: UIControlState.Normal)
    case .Medium:
    sender.setTitle("Medium", forState: UIControlState.Normal)
    }
    }
    */
    

    
}


