//
//  ArchiveTableViewController.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/16/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit

class ArchiveTableViewController: UITableViewController, UITextFieldDelegate{

    
    // MARK: Properties
    
    var rootFolder: Folder!
    var currentFolder: Folder!
    var folderCount = 0
    var addButton: UIBarButtonItem!
    var addFolderFlag = 0 //A flag for if we're adding a new folder or not
    var newRecording: Recording?
    
    // Used for error handling
    
    enum ArchiveError: ErrorType {
        
        case FolderDoesntExist
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert the '+' button in the navigation bar
        
        addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addFolder:")
        self.navigationItem.rightBarButtonItems = [addButton]
        
        // Setup the root folder incase no rootFolder exists on disk
        
        let rootFolderArray: [Folder] = []
        let rootRecordingArray: [Recording] = []
        
        rootFolder = Folder(name: "Root", parent: nil, folders: rootFolderArray, recordings: rootRecordingArray)
        saveFolder()
        // This try...catch is here so the program doesn't crash if the folder doesn't exists when we go to load data
        // Nothing happens within because regardless we want to pass rootFolder to currentFolder
        
        do {
            try rootFolder = loadFolder()
        } catch ArchiveError.FolderDoesntExist {
            
        } catch {
            
        }
        
        currentFolder = rootFolder
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // TESTING: newRecording = Recording(name: "Test", pins: [Pin](), urlPath: NSURL())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source
    
    
    // Determines the number of sections in the tableView

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
   
        return 1
    }

    // Determines the number of rows for the tableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        folderCount = 0 // Initialized here, used when configuring rows
        
        // If we are accessing the archive via the 'Archive' button in the recording screen
        
        if(newRecording == nil){
            
            if(currentFolder.parent == nil){ //root folder
                return currentFolder.folders.count + currentFolder.recordings.count + addFolderFlag
            }
            
            return currentFolder.folders.count + currentFolder.recordings.count + 1 + addFolderFlag //Includes parent so you can navigate back
        }
        
        // If we are accessing the archive in order to save a recording to a folder, in which case we don't want to show recordings
        
        if(currentFolder.parent == nil){ //root folder
            return currentFolder.folders.count + addFolderFlag
        }
        
        return currentFolder.folders.count + 1 + addFolderFlag //Includes parent so you can navigate back
        
    }

    // Configures the rows for the tableView
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Adds a row to the top of the tableView if a folder is being added
        
        if(addFolderFlag == 1){
            
            let cellIdentifier = "ArchiveNewTableViewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArchiveNewFolderTableViewCell
            
            cell.nameTextField.delegate = self
            
            return cell
        
        }
        
        //If the folder has a parent, include it as the top row so you can navigate back
        
        if((indexPath.row == 0 && currentFolder.parent != nil) || (indexPath.row == 1 && currentFolder.parent != nil && addFolderFlag == 1)){
            
            // Table view cells are reused and should be dequeued using a cell identifer
            
            let cellIdentifier = "ArchiveFolderTableViewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArchiveFolderTableViewCell
            
            
            // Fetches the appropriate data for the parent row

            let title = currentFolder.parent!.name
            let folder = currentFolder.parent!
            
            cell.expandFolderButton.hidden = true // Since this is for backwards navigation, we don't want the expandFolder button
            cell.folderLabel.text = title + " (Back)"
            cell.folder = folder
            
            return cell
        }
        
        // Add folder rows if necessary
        
        if(folderCount < currentFolder.folders.count){
            
            
            // Table view cells are reused and should be dequeued using a cell identifer
            
            let cellIdentifier = "ArchiveFolderTableViewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArchiveFolderTableViewCell
            
            // Fetches the appropriate data for the data source layout
            
            let title = currentFolder.folders[folderCount].name
            let folder = currentFolder.folders[folderCount]
            
            cell.folderLabel.text = title
            cell.folder = folder
            
            // If we're accessing the archive in order to save a recording, we use the expand folder button to expand the folder instead of the cell itself (since selecting the cell is how we determine where we save the recording)
            
            if(newRecording != nil){
                cell.expandFolderButton.hidden = false
                cell.viewController = self
            }
            
            folderCount++
            
            return cell
        
        }
        
        // Add recordings rows if necessary
        
        // We want to use indexPath.row to get our recording array element, however we need to account for any folder rows that have been inserted so we subtract from indexPath the # of rows that we have created prior to this to get our desired element in the recording array
        
        var adjustedRowIndex = indexPath.row - currentFolder.folders.count - addFolderFlag // Subtracts based on folder rows inserted
        if(currentFolder.parent != nil){ // Subtracts if there is a parent row
            
            adjustedRowIndex -= 1
        }
        
        // Table view cells are reused and should be dequeued using a cell identifer
        
        let cellIdentifier = "ArchiveTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArchiveTableViewCell
        
        // Fetches the appropriate data for the data source layout
        
        let title = currentFolder.recordings[adjustedRowIndex].name
        let recording = currentFolder.recordings[adjustedRowIndex]
        
        cell.titleLabel.text = title
        cell.recording = recording
        
        return cell
        
    }
    
    //Commented out the following as it was causing memory issues, may look into later
    /*
    // Defines the height of a cell based on its class
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
print("Issue: \(indexPath.row)")
        
        if let _ = tableView.cellForRowAtIndexPath(indexPath) as? ArchiveTableViewCell{
            
            return CGFloat(44)
        }
        
        return CGFloat(60)
    }
*/

    
    
    // Override to support conditional editing of the table view.
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // We don't want the backwards navigation row to be able to be edited
        
        if (currentFolder.parent != nil && indexPath.row == 0){
            return false
        }
        
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete the row from the data source
            
            // If the row is a folder, otherwise it's a recording
            
            if let _ = tableView.cellForRowAtIndexPath(indexPath) as? ArchiveFolderTableViewCell{
                currentFolder.folders.removeAtIndex(indexPath.row)
            }
            else{
                currentFolder.recordings.removeAtIndex(indexPath.row - currentFolder.folders.count)
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            saveFolder() // Save the rootFolder to reflect the deletion
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
            
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    
    // Is called whenever a table cell is selected
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?{
        
        //Checks if cell is a folder
        
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? ArchiveFolderTableViewCell {
            
            currentFolder = selectedCell.folder
            
            // Determines whether we're saving to a folder or not
            
            //We want the backwards navigation button (the parent) to function regardless of if we're saving to a folder
            if(newRecording == nil || (currentFolder.parent == nil && indexPath.row == 0)){
                
                tableView.reloadData()
            }
            else {
                
                selectedCell.selectionStyle = UITableViewCellSelectionStyle.Blue
                
                // We configure an Alert dialogue so the user can confirm they want to save to the chosen folder
                
                // Block of code that is run when the user confirms to save the recording
                let saveActionHandler = {(action: UIAlertAction!) -> Void in
                    
                    // We add the recording to the chosen folder, save, then return to the view that called the Archive
                
                    self.currentFolder.recordings.append(self.newRecording!)
                    self.saveFolder() // TESTING: Remove for testing. Until we start getting real data from the recorder, there will be an issue with having nil for the propreties of the Recordings
                    self.newRecording == nil // Set to nil so the archive is in its 'Search the Archive' state again
                    self.navigationController!.popViewControllerAnimated(true)
                }
                
                // Block of code that is run when the user cancels out
                let cancelActionHandler = {(action: UIAlertAction!) -> Void in
                    selectedCell.selected = false
                }
                
                // The save button
                let saveAction = UIAlertAction(title: "Ok", style: .Default, handler: saveActionHandler)
                // The cancel button
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelActionHandler)
                
                let saveMessage = "Save \(newRecording!.name) to \(currentFolder.name)?"
                // The alert controller itself
                let saveAlert = UIAlertController(title: "Archive", message: saveMessage, preferredStyle: .Alert)
                
                saveAlert.addAction(saveAction)
                saveAlert.addAction(cancelAction)
                
                self.presentViewController(saveAlert, animated: true, completion: nil)
                
            }
            
        }
        
        
        return indexPath
    }
    
    func addFolder(sender: UIBarButtonItem) {
        
        addFolderFlag = 1
        
        tableView.beginUpdates()
        
        let indexPath: [NSIndexPath] = [NSIndexPath(forRow: 0, inSection: 0)]
        tableView.insertRowsAtIndexPaths(indexPath, withRowAnimation: .Top)
        tableView.endUpdates()
        
        addFolderFlag = 0
        
    }
    
    
    // MARK: UITextFieldDelegate
    
    // Is called before the textfield gives up its first responder status (when the user presses Done). We use it to hide the keyboard
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        // Hide the keyboard
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // Called after textFieldShouldReturn. We create the new folder here
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let emptyFolder: [Folder] = []
        let emptyRecording: [Recording] = []
        
        currentFolder.folders.append(Folder(name: textField.text!, parent: currentFolder, folders: emptyFolder, recordings: emptyRecording))
        
        tableView.reloadData()
        
        saveFolder() // Save the rootFolder to reflect the new folder
        
        textField.text = ""
        
        /*
        // Delete the add folder row from the table
        
        tableView.beginUpdates()
        
        var indexPath: [NSIndexPath] = [NSIndexPath(forRow: 0, inSection: 0)]
        
        tableView.deleteRowsAtIndexPaths(indexPath, withRowAnimation: .Right)
        
        tableView.endUpdates()
        
    
print(textField.text! + "************" + currentFolder.folders[currentFolder.folders.count - 1].name)
        
        // Add the new folder row to the table
        
        tableView.beginUpdates()
        
        indexPath = [NSIndexPath(forRow: currentFolder.folders.count - 1, inSection: 0)]
        
        tableView.insertRowsAtIndexPaths(indexPath, withRowAnimation: .Top)
        
        tableView.endUpdates()
        
        
*/
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        saveFolder() // Save our rootFolder before the segue to be safe
        print("Saving")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
  
    
    
    // MARK: NSCoding
    
    // Save the rootFolder to disk
    
    func saveFolder(){
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(rootFolder, toFile: Folder.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            
            print("Failed to save rootFolder...")
        }
        
    }
    
    // Load data from disk
    
    func loadFolder() throws -> Folder {
        
        // Throws an error if the folder does not exist
        
        guard let test = NSKeyedUnarchiver.unarchiveObjectWithFile(Folder.ArchiveURL.path!) as? Folder else {
            
            throw ArchiveError.FolderDoesntExist
        }
        
        return test
    }

}







































































