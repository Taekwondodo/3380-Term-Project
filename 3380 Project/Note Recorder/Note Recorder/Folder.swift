//
//  Folder.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/18/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit //NSObject & NSCoding

//Tried simulating a linked list/tree type structure here. If parent = NULL then it is the root

class Folder: NSObject, NSCoding{
    
    
    // MARK: Properties
    
    var name: String
    var parent: Folder?
    var folders: [Folder] = []
    var recordings: [Recording] = []
    
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    //To reference the path created here: Meal.ArchiveURL.path!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("folder")
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let parentKey = "parent"
        static let foldersKey = "folders"
        static let recordingsKey = "recordings"
    }
    
    // MARK: Initialization
    
    init(name: String, parent: Folder?, folders: [Folder], recordings: [Recording]) {
        
        // Initialize stored parameters
        
        self.name = name
        self.parent = parent
        self.folders += folders
        self.recordings += recordings
        
        super.init() //For NSObject
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(parent, forKey:PropertyKey.parentKey)
        aCoder.encodeObject(folders, forKey:PropertyKey.foldersKey)
        aCoder.encodeObject(recordings, forKey:PropertyKey.recordingsKey)
 
    }
    
    
    //The required keyword means this initializer must be implemented on every subclass of the class that defines this initializer.
    //The convenience keyword denotes this initializer as a convenience initializer. Convenience initializers are secondary, supporting initializers that need to call one of their class’s designated initializers. Designated initializers are the primary initializers for a class. They fully initialize all properties introduced by that class and call a superclass initializer to continue the initialization process up the superclass chain. Here, you’re declaring this initializer as a convenience initializer because it only applies when there’s saved data to be loaded.
    //The question mark means that this is a failable initializer that might return nil
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        //When you decode data based on a key, you need to force type cast it so that if the returned value isn't the expected type, the program crashes as an issue has occured
        
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        //Since the Folder variable is an optional (?), it can return nil when casted
        let parent = aDecoder.decodeObjectForKey(PropertyKey.parentKey) as? Folder
        
        let folders = aDecoder.decodeObjectForKey(PropertyKey.foldersKey) as? [Folder]
        
        let recordings = aDecoder.decodeObjectForKey(PropertyKey.recordingsKey) as! [Recording]
        
        
        // Must call designated initializer
        self.init(name: name, parent:parent, folders:folders, recordings:recordings)
    }
    
    
}