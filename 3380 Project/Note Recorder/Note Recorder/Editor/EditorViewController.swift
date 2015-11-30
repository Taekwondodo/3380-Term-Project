//
//  EditorViewController.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/17/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit
import AVFoundation

class EditorViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var waveform: SCScrollableWaveformView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    
    var recording: Recording!
    var recordingName: String!
    let recordingType = "m4a"
    // test pin timestamps
    var timeStampArray: [Float64] = []
    var pinArrayMax: Int!
    //var max = timeStampArray.endIndex
    var i: Int = 0
    var j: Int = 0
    // test pin timestamps
    
    var playAudioURL: NSURL!
    var playAudioPlayer = AVPlayer()
    //var playRecPlayer = AVAudioPlayer()
    
    var observer: AnyObject? = nil
    var observerPin: AnyObject? = nil
    var AVPlayerItemDidReachPinNotification: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        //
        
        //do{
        // playRecPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("test", ofType:"m4a")!))
        // } catch{
        //     print(error)
        // }
        
        recordingName = recording.name
        pinArrayMax = recording.pins.count
        playAudioURL = recording.urlPath

        for pin in recording.pins{
            timeStampArray.append(Float64(pin.timeStamp))
        
        }
        
        self.navigationItem.title = recordingName // Replaces the title label
        speedLabel.text = "1.0X"
        
        self.waveform.waveformView.precision = 1 //prevly,scrollableWaveformView
        self.waveform.waveformView.lineWidthRatio = 1
        self.waveform.waveformView.normalColor = UIColor(red:0.5, green:0.1, blue:0.9, alpha: 1)
        self.waveform.waveformView.channelsPadding = 10
        self.waveform.waveformView.progressColor = UIColor(red:0.3, green:0.1, blue:0.5, alpha: 1)
        //
        //AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"m4a"] options:nil];
        
        var asset = AVURLAsset(URL: playAudioURL, options: nil)
        //asset = init(playAudioURL: NSURL, )
        
        
        //AVURLAsset asset =
        //
        self.waveform.alpha = 0.8
        
        self.waveform.waveformView.asset = asset
        //var progressTime = CMTime?
        var timeVar = Float64(self.slider.value) * CMTimeGetSeconds(self.waveform.waveformView.asset.duration)
        
        var progressTime: CMTime = CMTimeMakeWithSeconds(timeVar,100000);
        
        self.waveform.waveformView.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(15, 10000), progressTime);
        
        
        
        //    playAudioPlayer = AVPlayer(contentsOfURL: playAudioURL, error: nil)
        //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playReachedEnd: name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        
        //__unsafe_unretained SCViewController *mySelf = self;
        
        //var mySelf: SCViewController = self
        
        // _observer = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // mySelf.scrollableWaveformView.waveformView.progressTime = time;
        //}];
        
        do{
            playAudioPlayer = try AVPlayer(URL: playAudioURL)
        } catch {
            print(error)
        }
        
        
        //   var filePath = NSString(string: NSBundle.mainBundle().pathForResource("TchaikovskyExample2",ofType: "m4a")!)
        //   var fileURL = NSURL(fileURLWithPath: filePath as String)
        
        //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        
        //   __unsafe_unretained SCViewController *mySelf = self;
        //  _observer = [playAudioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //   mySelf.scrollableWaveformView.waveformView.progressTime = time;
        //  }];
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playReachedEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playAudioPlayer.currentItem)
        
        var mySelf: EditorViewController = self
        observer = playAudioPlayer.addPeriodicTimeObserverForInterval(CMTimeMake(1, 60), queue: dispatch_get_main_queue(), usingBlock: {(time: CMTime) -> Void in
            mySelf.waveform.waveformView.progressTime = time
        })
        
        // play reached next pin
        //      NSNotificationCenter.defaultCenter().addObserver(self, selector: "playReachedPin:", name: AVPlayerItemDidReachPinNotification, object: playAudioPlayer.currentItem)
        
        
        //var mySelf: ViewController = self
        //     observerPin = playAudioPlayer.addPeriodicTimeObserverForInterval(CMTimeMake(1, 60), queue: dispatch_get_main_queue(), usingBlock: {(time: CMTime) -> Void in
        //              mySelf.waveform.waveformView.progressTime = time
        //         })
        //
        
        
    }
    
    @objc func playReachedEnd(notification: NSNotification) {
        if (notification.object === playAudioPlayer.currentItem) {
            playAudioPlayer.seekToTime(kCMTimeZero)
            playAudioPlayer.pause()
            playButton.setTitle("Play", forState: UIControlState.Normal)
            self.slider.value = 0.5
            self.speedLabel.text = "\(self.slider.value*2)" + "X"
            i = 0
            j = 0
        }
    }
    
    //
    //   @objc func playReachedPin(notification: NSNotification) {
    //       var pinTimeStamp = timeStampArray[i]
    //       var pinTime: CMTime = CMTimeMakeWithSeconds(pinTimeStamp, 1)
    //       if ((playAudioPlayer.currentTime() >= pinTime) && (i < pinArrayMax)) {
    //           pinTimeStamp = timeStampArray[i]
    //          pinTime = CMTimeMakeWithSeconds(pinTimeStamp, 1)
    //          while((playAudioPlayer.currentTime() > pinTime) && (j <= pinArrayMax)){
    //              pinTimeStamp = timeStampArray[j]
    //              pinTime = CMTimeMakeWithSeconds(pinTimeStamp, 1)
    //              i = i + 1
    //          }
    //          playAudioPlayer.seekToTime(pinTime)
    //          playAudioPlayer.pause()
    //         if(i < pinArrayMax){
    //              i = i + 1
    //          }
    //      }
    //          playButton.setTitle("Play", forState: UIControlState.Normal)
    //          //self.slider.value = 0.5
    //          //self.speedLabel.text = "\(self.slider.value*2)" + "X"
    //      }
    //      i = i + 1
    // }
    //
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        playAudioPlayer.removeTimeObserver(observer!)
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        //playAudioPlayer.removeTimeObserver(observerPin!)
    }
    
    
    @IBAction func stopButton(sender: AnyObject) {
        playAudioPlayer.pause()
        playAudioPlayer.seekToTime(kCMTimeZero)
        playButton.setTitle("Play", forState: UIControlState.Normal)
        self.slider.value = 0.5
        self.speedLabel.text = "\(self.slider.value*2)" + "X"
        playAudioPlayer.rate = 0.0
        i = 0
        j = 0
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
        //self.waveform.waveformView.progressTime.value =
        if(j <= pinArrayMax){
            var nextPinTimeStamp = timeStampArray[j]
            var nextPinTime: CMTime = CMTimeMakeWithSeconds(nextPinTimeStamp, 1)
            while((playAudioPlayer.currentTime() > nextPinTime) && (j <= pinArrayMax)){
                nextPinTimeStamp = timeStampArray[j]
                nextPinTime = CMTimeMakeWithSeconds(nextPinTimeStamp, 1)
                j = j + 1
            }
            if(playAudioPlayer.currentTime() < nextPinTime){
                playAudioPlayer.seekToTime(nextPinTime)
            }
            if(j <= pinArrayMax){
                j = j + 1
            }
            
            //self.waveform.waveformView.progressTime
            
        }
        
    }
    
    @IBAction func speedSlider(sender: AnyObject) {
        //if(playAudioPlayer.rate >= 0.0){
        self.playAudioPlayer.rate = self.slider.value * 2
        var speedToOneD = (round(self.slider.value*20))/10
        self.speedLabel.text = "\(speedToOneD)" + "X"
        if((playButton.currentTitle == "Play") && (playAudioPlayer.rate > 0.0)){
            playButton.setTitle("Pause", forState: UIControlState.Normal)
        }
        //}
        //else{
        //     playAudioPlayer.rate = 0.0
        // }
        
        
        //    self.waveform.waveformView.timeRange = CMTimeRangeMake(start, duration);
    }
    
    //   override func didReceiveMemoryWarning() {
    //      super.didReceiveMemoryWarning()
    //     // Dispose of any resources that can be recreated.
    //  }
    
    //func handleTapGesture(recognizer: UITapGestureRecognizer) {
    //    playAudioPlayer.seekToTime()
    
    // }

    
    // MARK: Navigation
    
    // If the user decides to return to the Archive
    
    @IBAction func dismiss(sender: UIBarButtonItem){
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // We won't need this if we aren't altering the audio file
    /*
    // Preparing for the save
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destination = segue.destinationViewController as? ArchiveTableViewController
        
        destination?.previousController = self
        
        // TODO: Pass your recording here
        // destination?.newRecording = yourRecording
        
    }
    */
}

























































































