//
//  VideoTrimController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 3/4/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class VideoTrimController: UIViewController, UITextFieldDelegate {
    
    var vidUrl: NSURL?
    
    var vidExpUrl: NSURL?
    
    var start: Double?
    var end: Double?
    var duration: Double?
    
    @IBOutlet var startTime: UITextField!
    @IBOutlet var endTime: UITextField!
    
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var saveBtn: UIButton!
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTime.delegate = self
        endTime.delegate = self
        
        saveBtn.addTarget(self, action: "saveAction:", forControlEvents: UIControlEvents.TouchUpInside)

        
        cancelBtn.addTarget(self, action: "cancelAction:", forControlEvents: UIControlEvents.TouchUpInside)
        print("vid1",vidUrl)
        print("vid2",vidExpUrl)
    }
    
    


func saveAction(sender: UIButton) {
    start = Double(startTime.text!)!
    end = Double(endTime.text!)!
    duration = end! - start!
    
    let vidDuration = getMediaDuration(vidExpUrl)
    
    print("vidDuration",vidDuration)
    print("save")
    print("startT",start)
    print("endT",end)
    print("duration",duration)
    
    if((start < end) && (duration <= vidDuration) && (end <= vidDuration)) {

        print("vidExpUrl",vidExpUrl!)
        let components = NSURLComponents(URL: vidUrl!, resolvingAgainstBaseURL: false)
        let queryItems = components!.queryItems!
        
        let id = queryItems.filter({$0.name == "id"}).first?.value
        
        print("bc")
        /* video upload and conversion to NSData */
        let vidAsset = AVAsset(URL: vidExpUrl!)
        let clipVideoTrack = vidAsset.tracksWithMediaType(AVMediaTypeVideo).first! as AVAssetTrack
        
        let exportPath: NSString = NSTemporaryDirectory().stringByAppendingFormat("\(id!).mp4")
        print("exportPath",exportPath)
        let exportUrl: NSURL = NSURL.fileURLWithPath(exportPath as String)
        
        let startTime: CMTime = CMTimeMakeWithSeconds(start!, 600)
        let duration: CMTime = CMTimeMakeWithSeconds(self.duration!, 600)
        let range: CMTimeRange = CMTimeRangeMake(startTime, duration)
        
        
        let vidExp :AVAssetExportSession = AVAssetExportSession(asset: vidAsset, presetName: AVAssetExportPresetHighestQuality)!
        //    vidExp.videoComposition = videoComposition
        vidExp.outputURL = exportUrl
        vidExp.outputFileType = AVFileTypeMPEG4 //AVFileTypeQuickTimeMovie
        vidExp.timeRange = range
        removeFileAtURLIfExists(vidExp.outputURL!)
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
                    validVC.vidUrl = self.vidUrl!
                    if let capturedVideo = vidExp.outputURL {
                        validVC.vidExpUrl = capturedVideo
                        //    self.presentViewController(validVC, animated: true, completion: nil)
                    }
                    self.presentViewController(validVC, animated: true, completion: nil)
                }
                
            }
        })
        
    }
    else {
        let alert = UIAlertController(title: "Enter correct timings", message:"Please enter duration of video less than \(vidDuration)s ", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
            // PERFORM ACTION
            })
        self.presentViewController(alert, animated: true){}
    }
    
    
    
    
}
    
func cancelAction(sender: UIButton) {
    print("cancel")
}

    func getMediaDuration(url: NSURL!) -> Float64 {
        let asset : AVURLAsset = AVURLAsset(URL: url)
        let duration : CMTime = asset.duration
        
        return CMTimeGetSeconds(duration)
    }
    
    func sendExportVideo(vidLink: NSURL) {

    }
    
    func removeFileAtURLIfExists(url: NSURL) {
        if let filePath = url.path {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(filePath) {
                var error: NSError?
                
                do {
                    try fileManager.removeItemAtPath(filePath as String)
                } catch {
                    // Error - handle if required
                    print("error")
                }
            }
        }
    }    
    
    

}