//
//  Recording.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/18/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit

class Recording: NSObject, NSCoding{
    
    // MARK: Properties
    
    var name: String
    var pins: [Pin] = []
    var urlPath: NSURL // Playing & recording are based on the url of the audio file you pass to the function, so this is all we need to identify the recording
    
    
    // MARK: Types
    
    //We can use NSDate to parse/manipulate/whatever the strings. The following is a reference
    //http://stackoverflow.com/questions/24089999/how-do-you-create-a-swift-date-object
    

    struct PropertyKey{
        
        static let nameKey = "name"
        static let pinsKey = "pins"
        static let urlPathKey = "urlPath"
    }
    
    
    // MARK: Initialization
    
    init(name: String, pins: [Pin], urlPath: NSURL) {
        
        // Initialize stored parameters
        
        self.name = name
        self.pins = pins
        self.urlPath = urlPath
     
        // Call parent initializer
        
        super.init()
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(pins, forKey: PropertyKey.pinsKey)
        aCoder.encodeObject(urlPath, forKey: PropertyKey.urlPathKey)
        
    }
    
    
    //The required keyword means this initializer must be implemented on every subclass of the class that defines this initializer.
    //The convenience keyword denotes this initializer as a convenience initializer. Convenience initializers are secondary, supporting initializers that need to call one of their class’s designated initializers. Designated initializers are the primary initializers for a class. They fully initialize all properties introduced by that class and call a superclass initializer to continue the initialization process up the superclass chain. Here, you’re declaring this initializer as a convenience initializer because it only applies when there’s saved data to be loaded.
    //The question mark means that this is a failable initializer that might return nil
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        //When you decode data based on a key, you need to force type cast it so that if the returned value isn't the expected type, the program crashes as an issue has occured
        
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        let pins = aDecoder.decodeObjectForKey(PropertyKey.pinsKey) as! [Pin]
        
        let urlPath = aDecoder.decodeObjectForKey(PropertyKey.urlPathKey) as! NSURL
        
        // Must call designated initializer
        
        self.init(name: name, pins: pins, urlPath: urlPath)
        
    }
    
}


