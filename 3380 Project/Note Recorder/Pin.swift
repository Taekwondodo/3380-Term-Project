//
//  Pin.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/27/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit

class Pin: NSObject, NSCoding{
    
    // MARK: Properties
    
    var comment: String?
    var timeStamp: NSTimeInterval
    
    
    // MARK: Types
    
    struct PropertyKey{
        
        static let commentKey = "comments"
        static let timeStampKey = "timeStamp"
    }
    
    
    // MARK: Initialization
    
    init(comment: String?, timeStamp: NSTimeInterval) {
        
        // Initialize stored parameters
        
        self.comment = comment
        self.timeStamp = timeStamp
        
        // Call parent initializer
        
        super.init()
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(comment, forKey: PropertyKey.commentKey)
        aCoder.encodeObject(timeStamp, forKey: PropertyKey.timeStampKey)
        
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        //When you decode data based on a key, you need to force type cast it so that if the returned value isn't the expected type, the program crashes as an issue has occured
        
        let comment = aDecoder.decodeObjectForKey(PropertyKey.commentKey) as? String
        
        let timeStamp = aDecoder.decodeObjectForKey(PropertyKey.timeStampKey) as! NSTimeInterval
        
        
        // Must call designated initializer
        
        self.init(comment: comment, timeStamp: timeStamp)
    }
}