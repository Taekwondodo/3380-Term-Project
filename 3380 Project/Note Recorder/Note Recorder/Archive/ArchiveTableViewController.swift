//
//  ArchiveTableViewController.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/16/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit

class ArchiveTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate{

    
    // MARK: Properties
    
    
    var rootFolder: Folder!
    var currentFolder: Folder!
    var folderCount = 0
    var addButton: UIBarButtonItem!
    var addFolder = 0 //Essentially a flag for if we're adding a new folder or not


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addFolder:")
        self.navigationItem.rightBarButtonItems = [addButton]
        
        // May not need all of this root setup when we're loading data from memory
        
        let rootFolderArray: [Folder] = []
        let rootRecordingArray: [Recording] = []
        
        rootFolder = Folder(name: "Root", parent: nil, folders: rootFolderArray, recordings: rootRecordingArray)
        
        loadTestData()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadTestData(){ // for testing purposes, will be removed in final version
        
        let emptyFolder: [Folder] = []
        let emptyRecording: [Recording] = []
        
        let dummyFolder = Folder(name: "empty1", parent: rootFolder, folders: emptyFolder, recordings: emptyRecording)
        let dummyArray = [dummyFolder, dummyFolder]
        let tempRecording1 = Recording(name: "sub1")
        let tempRecording2 = Recording(name: "sub2")
        let recordingArray: [Recording] = [tempRecording1, tempRecording2]
        tempRecording1.name = "3"
        tempRecording2.name = "4"
        let recordingArray2: [Recording] = [tempRecording1, tempRecording2]
        
        let tempFolder1 = Folder(name: "1", parent: rootFolder, folders: dummyArray, recordings: recordingArray)
        let tempFolder2 = Folder(name: "2", parent: rootFolder, folders: dummyArray, recordings: recordingArray2)
        let folderArray: [Folder] = [tempFolder1, tempFolder2]
     
        rootFolder.folders = folderArray
        rootFolder.recordings = recordingArray
        currentFolder = rootFolder
    }
    

    // MARK: - Table view data source
    
    // Determines the number of sections in the tableView

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
   
        return 1
    }

    // Determines the number of rows for the tableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        folderCount = 0 // Initialized here, used when configuring rows
        
        if(currentFolder.parent == nil){ //root folder
            return currentFolder.folders.count + currentFolder.recordings.count + addFolder
        }
        
        return currentFolder.folders.count + currentFolder.recordings.count + 1 + addFolder //Includes parent so you can navigate back
        
    }

    // Configures the rows for the tableView
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Adds a row to the top of the tableView if a folder is being added
        
        if(addFolder == 1){
            
            let cellIdentifier = "ArchiveNewFolderTableViewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArchiveNewFolderTableViewCell
            
            return cell
        
        }
        
        //If the folder has a parent, include it as the top row so you can navigate back
        
        if((indexPath.row == 0 && currentFolder.parent != nil) || (indexPath.row == 1 && currentFolder.parent != nil && addFolder == 1)){
            
            // Table view cells are reused and should be dequeued using a cell identifer
            
            let cellIdentifier = "ArchiveFolderTableViewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArchiveFolderTableViewCell
            
            // Fetches the appropriate data for the parent row
            
            let title = currentFolder.parent!.name
            let folder = currentFolder.parent!
            
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
            
            folderCount++
            
            return cell
        
        }
        
        // Add recordings rows if necessary
        // We want to use indexPath.row to get our recording array element, however we need to account for any folder rows that have been inserted so we subtract from indexPath the # of rows that we have created prior to this to get our desired element in the recording array
        
        var adjustedRowIndex = indexPath.row - currentFolder.folders.count + addFolder // Subtracts based on folder rows inserted
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
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // We don't want the backwards navigation row to be able to be edited
        
        if (currentFolder.parent != nil && indexPath.row == 0){
            return false
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    
        
        
        return UITableViewCellEditingStyle.Delete
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
            
            tableView.reloadData()
        }
        
        
        return indexPath
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let popOver = segue.destinationViewController.popoverPresentationController
        
        popOver?.sourceRect = popOver!.sourceView!.bounds;
    }
    
    
    
    func addFolder(sender: UIBarButtonItem) {
        
        addFolder = 1
        
        tableView.beginUpdates()
        
        let indexPath: [NSIndexPath] = [NSIndexPath(forRow: 0, inSection: 0)]

        tableView.insertRowsAtIndexPaths(indexPath, withRowAnimation: .Top)
        
        tableView.endUpdates()
        
        addFolder = 0
        
        /*
        let popoverViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EnterTextUIViewController") as UIViewController?
        popoverViewController?.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        let popOver = self.popoverPresentationController
        popOver!.permittedArrowDirections = .Any
        popOver!.delegate = self
        popOver!.barButtonItem = sender as UIBarButtonItem
        popOver!.popoverLayoutMargins = UIEdgeInsetsMake(300, 300, 300, 300)
        
        
        presentViewController(popoverViewController!, animated: true, completion: nil)
        
        
        self.performSegueWithIdentifier("enterFolderName", sender: addButton)
        */
    }
    
    //func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
  //      return .None
    //}

}







































































