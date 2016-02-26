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
                    let vc: VideoViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("ImageVC") as? VideoViewController
                    if let validVC: VideoViewController = vc {
                        if let capturedImage = videoURL {
                            validVC.vidUrl = capturedImage
                            self.presentViewController(validVC, animated: true, completion: nil)
                        }
                    }
                    }
                    else {
                        let alert = UIAlertController(title: "Error! Video too long.", message:"Please record a video with duration less than 30s", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                            // PERFORM ACTION
                            })
                        self.presentViewController(alert, animated: true){}
                        
                        
                    }
                }
            })
        }
        
    }
    func timerAction() {
        ++counter
        camTimer.text = "\(counter)"
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


