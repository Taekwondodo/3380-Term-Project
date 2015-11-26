//
//  EditorViewController.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/17/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var waveform: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        button.addTarget(self, action: "createImage", forControlEvents:.TouchDown)
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createImage(){
        
        // Setup the current graphics context
        let maxY = waveform.layer.frame.maxY
        let midY = waveform.layer.frame.midY
        let minX = waveform.layer.frame.minX
        let maxX = waveform.layer.frame.maxX
        let height = waveform.layer.frame.height
        let width = waveform.layer.frame.width
        
        UIGraphicsBeginImageContext(waveform.layer.frame.size)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetGrayStrokeColor(context, 0.0, 1.0)
        CGContextSetLineWidth(context, 1.0)
        
        // Create the path for black x-axis line
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, minX, height/2.0)
        CGContextAddLineToPoint(context, maxX, height/2.0)

        // Draw the path
        
        CGContextStrokePath(context)
        
        CGContextSetGrayStrokeColor(context, 0.5, 1.0)
        CGContextSetLineWidth(context, 1.0)
        
        var x = minX
        
        while(x <= maxX){
            
            let randomHeight = Float((random())) % Float(height.native/2)
            
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, x, height/2.0)
            CGContextAddLineToPoint(context, x, height/2 + CGFloat(randomHeight))
            CGContextAddLineToPoint(context, x, height/2 + CGFloat(0 - randomHeight))

            CGContextStrokePath(context)
            
            waveform.image = UIGraphicsGetImageFromCurrentImageContext()
            //waveform.displayLayer(waveform.layer)
            
            sleep(1)
            
            x += (maxX / 80)
            
            
        }
        
    
 
       UIGraphicsEndImageContext()
        
    }
    
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
