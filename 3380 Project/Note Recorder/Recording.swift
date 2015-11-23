//
//  Recording.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/18/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit

class Recording{
    
    // MARK: Properties
    
    var name: String
    //var pins: [Pins] = [] removed for testing purposes
    //var urlPath: NSURL // Playing & recording are based on the url of the audio file you pass to the function, so this is all we need to identify the recording
    
    
    // MARK: Types
    
    //We could just do a 2-dim array instead, but I thought a struct was a bit cleaner
    //We can use NSDate to parse/manipulate/whatever the strings. The following is a reference
    //http://stackoverflow.com/questions/24089999/how-do-you-create-a-swift-date-object
    
    struct Pins{
        var comment: String?
        var timestamp: String
    }
    
    
    // MARK: Initialization
    
    init(name: String) {
        
        // Initialize stored parameters
        
        self.name = name
        //self.pins += pins
     
        
    }
    
    
    
    
}
