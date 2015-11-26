//
//  RecorderViewController.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/16/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController,AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    // Create outlets for buttons on storyboard.
    @IBOutlet weak var RecordBtn: UIButton!
    @IBOutlet weak var PlayBtn: UIButton!
    @IBOutlet weak var MarkTimeBtn: UIButton!
    
    // Create instances of recorder and player.
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var timeMarked = [NSTimeInterval]()
    var i = 0
    var a = 0
    var x = CGFloat(1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupRecorder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Record audio when "Record" button is clicked
    @IBAction func recordSound(sender: UIButton) {
        if sender.titleLabel?.text == "Record"{
            soundRecorder.record()
            sender.setTitle("Stop", forState: .Normal)
            PlayBtn.enabled = false
            MarkTimeBtn.enabled = true
        } else {
            soundRecorder.stop()
            sender.setTitle("Record", forState: .Normal)
            PlayBtn.enabled = false
        }
    }
    
    // Play last recorded audio when "Play" button is clicked.
    @IBAction func playSound(sender: UIButton) {
        if sender.titleLabel?.text == "Play" {
            RecordBtn.enabled = false
            MarkTimeBtn.enabled = false
            sender.setTitle("Stop", forState: .Normal)
            preparePlayer()
            soundPlayer.play()
        } else {
            soundPlayer.stop()
            RecordBtn.enabled = true
            MarkTimeBtn.enabled = false
            sender.setTitle("Play", forState: .Normal)
        }
    }
    
    // Add current time of recording at moment when "Mark" button is clicked.
    @IBAction func markTime(sender: UIButton) {
        timeMarked.append(round(100*soundRecorder.currentTime)/100)
        print(soundRecorder.currentTime)
        addButton()
        i++
    }
    
    // Add button for each time marked when "Mark" button is clicked.
    func addButton() {
        let button = UIButton(type: UIButtonType.System) as UIButton
        button.frame = CGRectMake(60, 300+(32*x), 300, 50)
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle(String(timeMarked[i]), forState: .Normal)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(button)
        x++
    }
    
    // Make playback time match the title of the button.
    func buttonAction(sender:UIButton!) {
        if String(timeMarked[a]) == sender.titleLabel?.text {
            
            preparePlayer()
            if soundPlayer.playing {
                soundPlayer.stop()
            }
            soundPlayer.currentTime = timeMarked[a]
            soundPlayer.play()
            a = 0
        } else {
            a++
            btnAction(sender.titleLabel?.text)
        }
    }
    
    // Ugly hack, will fix.
    func btnAction(name:String?) {
        if String(timeMarked[a]) == name {
            
            preparePlayer()
            if soundPlayer.playing {
                soundPlayer.stop()
            }
            soundPlayer.currentTime = timeMarked[a]
            soundPlayer.play()
            a = 0
        } else {
            a++
            btnAction(name)
        }
    }
    
    // Set recorder settings and file location.
    func setupRecorder() {
        let audioURL = RecorderViewController.getFileURL()
        print(audioURL.absoluteString)
        
        let recordSettings = [AVFormatIDKey : Int(kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey : 2 as NSNumber,
            AVSampleRateKey : 44100.0 ]
        
        var error : NSError?
        do{
            soundRecorder = try AVAudioRecorder(URL: audioURL, settings: recordSettings)
            soundRecorder.delegate = self
        } catch {
            finishRecording(success : false)
        }
        if let err = error{
            NSLog("Somethings wrong.")
        } else {
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        }
    }
    
    // Create URL and name audio file.
    class func getFileURL() -> NSURL {
        let path = getCacheDirectory().stringByAppendingPathComponent("audio.m4a")
        let filePath = NSURL(fileURLWithPath: path)
        
        return filePath
    }
    
    // Find audio file URL
    class func getCacheDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        let cacheDirectory = paths[0]
        
        return cacheDirectory
    }
    
    // Error checking...
    func finishRecording(success success: Bool) {
        soundRecorder.stop()
        RecordBtn.setTitle("Record", forState: .Normal)
        
        let ac = UIAlertController(title: "Record failed", message: "There was a problem recording.", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    // Find audio file and set playback settings.
    func preparePlayer() {
        var error : NSError?
        do{
            soundPlayer = try AVAudioPlayer(contentsOfURL: RecorderViewController.getFileURL())
        } catch {
            
        }
        
        if let err = error{
            NSLog("Bad.")
        } else {
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        }
    }
    
    // Re-enable "Play" button after recording is stopped.
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        PlayBtn.enabled = true
    }
    
    // Re-enable "Record" button after playback is stopped, change "Play" button title from "Stop" back to "Play".
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        RecordBtn.enabled = true
        PlayBtn.setTitle("Play", forState: .Normal)
    }
}