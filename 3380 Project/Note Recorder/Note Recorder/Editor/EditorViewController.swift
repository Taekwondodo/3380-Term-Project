//
//  EditorViewController.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/17/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit
import AVFoundation

class EditorViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate,UIScrollViewDelegate {
    
    
    @IBOutlet weak var waveform: SCScrollableWaveformView!
    //@IBOutlet weak var waveform: SCScrollableWaveformView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    //@IBOutlet weak var speedLabel: UISlider!
    @IBOutlet weak var speedLabel: UILabel!

    //@IBOutlet weak var commentField: UITextField!
    //@IBOutlet weak var commentView: UITextView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var commentView: UITextView!
    
    var recording: Recording!
    var recordingName: String!
    //let recordingName = "test" //delete
    let recordingType = "m4a"
    var timeStampArray = [CMTime]()
    var pinArrayMax = 0
    var commentArray: [String] = []
    var timeStampAnyArray: NSMutableArray = []
    var j: Int = -1
    
    var playAudioURL: NSURL!
    //var playAudioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("08 fireside",ofType: "mp3")!) //delete
    var playAudioPlayer = AVPlayer()
    
    var observer: AnyObject? = nil
    var observerPin: AnyObject? = nil
    var AVPlayerItemDidReachPinNotification: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
print("Editor")
            playAudioURL = recording.urlPath!
print("\(playAudioURL.absoluteString)")
            recordingName = recording.name
            for pin in recording.pins!{
                timeStampArray.append(CMTimeMakeWithSeconds(Float64(pin.timeStamp), 1))
                commentArray.append(" ")
            }
        
        self.navigationItem.title = recordingName
        speedLabel.text = "1.0X"
        self.waveform.waveformView.precision = 1
        
        self.waveform.waveformView.lineWidthRatio = 1
        self.waveform.waveformView.normalColor = UIColor(red:0.5, green:0.1, blue:0.9, alpha: 1)
        self.waveform.waveformView.channelsPadding = 10
        self.waveform.waveformView.progressColor = UIColor(red:0.3, green:0.1, blue:0.5, alpha: 1)
        var asset = AVURLAsset(URL: playAudioURL, options: nil)
        self.waveform.alpha = 0.8
        self.waveform.waveformView.asset = asset
        self.waveform.waveformView.audioURL = playAudioURL
        var array: [AnyObject] = [AnyObject]()
        
        var timeVar = Float64(self.slider.value) * CMTimeGetSeconds(self.waveform.waveformView.asset.duration)
        
        var progressTime: CMTime = CMTimeMakeWithSeconds(timeVar,100000);
        
        self.waveform.waveformView.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(15, 10000), progressTime);
        
        
      //  do{
     //       playAudioPlayer = try AVPlayer(URL: playAudioURL)
      //  } catch {
      //      print(error)
      //  }

     
        self.waveform.waveformView.audioPlayer = playAudioPlayer
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playReachedEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playAudioPlayer.currentItem)
        
        var mySelf: EditorViewController = self
        observer = playAudioPlayer.addPeriodicTimeObserverForInterval(CMTimeMake(1, 60), queue: dispatch_get_main_queue(), usingBlock: {(time: CMTime) -> Void in
            mySelf.waveform.waveformView.progressTime = time
            var k = 0
            while(k < self.timeStampArray.count && mySelf.waveform.waveformView.progressTime > self.timeStampArray[k]){
                k++
            }
            if(k == 0){
                self.j = 0
            }
            else{
                self.j = k-1
            }
        })
    }
    
    @objc func playReachedEnd(notification: NSNotification) {
        if (notification.object === playAudioPlayer.currentItem) {
            playAudioPlayer.seekToTime(kCMTimeZero)
            playAudioPlayer.pause()
            playButton.setTitle("Play", forState: UIControlState.Normal)
            self.slider.value = 0.5
            self.speedLabel.text = "\(self.slider.value*2)" + "X"
            j = 0
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        playAudioPlayer.removeTimeObserver(observer!)
    }
    
    @IBAction func stopButton(sender: AnyObject) {
        playAudioPlayer.pause()
        playAudioPlayer.seekToTime(kCMTimeZero)
        playButton.setTitle("Play", forState: UIControlState.Normal)
        self.slider.value = 0.5
        self.speedLabel.text = "\(self.slider.value*2)" + "X"
        playAudioPlayer.rate = 0.0
        j = 0
        commentView.text = " "
        commentField.text = " "
    }
    
    @IBAction func playButton(sender: AnyObject) {
        if (playAudioPlayer.rate > 0.0){
            playAudioPlayer.pause()
            playButton.setTitle("Play", forState: UIControlState.Normal)
        }
        else{
            playAudioPlayer.play()
            playButton.setTitle("Pause", forState: UIControlState.Normal)
        }
        
    }
    
    @IBAction func nextPin(sender: AnyObject) {
        if( j < timeStampArray.count && j != -1){
            var nextPinTime: CMTime = timeStampArray[j]
            while((playAudioPlayer.currentTime() > nextPinTime) && (j < timeStampArray.count-1)){
                j = j + 1
                nextPinTime = timeStampArray[j]
            }
            if(playAudioPlayer.currentTime() == nextPinTime && j < timeStampArray.count-1){
                nextPinTime = timeStampArray[j+1]
                playAudioPlayer.seekToTime(nextPinTime)
                commentView.text = commentArray[j+1]
            }
            if(playAudioPlayer.currentTime() < nextPinTime){
                playAudioPlayer.seekToTime(nextPinTime)
                commentView.text = commentArray[j]
            }
        }
    }
    
    @IBAction func speedSlider(sender: AnyObject) {
        self.playAudioPlayer.rate = self.slider.value * 2
        var speedToOneD = (round(self.slider.value*20))/10
        self.speedLabel.text = "\(speedToOneD)" + "X"
        if((playButton.currentTitle == "Play") && (playAudioPlayer.rate > 0.0)){
            playButton.setTitle("Pause", forState: UIControlState.Normal)
        }
        
    }
    @IBAction func createPin(sender: AnyObject) {
        var newTime: CMTime = playAudioPlayer.currentTime()
        timeStampArray.append(newTime)
        commentArray.append(" ")
        commentField.text = " "
        var newStamp = timeStampArray.last
        var newComment = commentArray.last
        timeStampArray.sortInPlace()
        var idx = timeStampArray.indexOf(newStamp!)
        commentArray.insert(newComment!, atIndex: idx!)
        j = j + 1
        pinArrayMax = pinArrayMax + 1
        
    }
    @IBAction func commentField(sender: UITextField, forEvent event: UIEvent) {
        if( j < timeStampArray.count && j != -1){
            commentArray[j]=(commentField.text!)
        }
    }
    
    // MARK: Navigation
    
    // If the user decides to return to the Archive
    
    @IBAction func dismiss(sender: UIBarButtonItem){
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
