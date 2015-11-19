//
//  ArchiveTableViewController.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/16/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit

class ArchiveTableViewController: UITableViewController{

    
    // MARK: Properties
    
    
    var rootFolder: Folder!
    var currentFolder: Folder!
    var folderCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootFolder = Folder(name: "Root", parent: nil, folders: nil, recordings: nil, shown: true)
        
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
    
    
    func loadTestData(){
        
        let dummyFolder = Folder(name: "", parent: nil, folders: nil, recordings: nil, shown:false)
        let dummyArray = [dummyFolder, dummyFolder]
        let tempRecording1 = Recording(name: "sub1")
        let tempRecording2 = Recording(name: "sub2")
        let recordingArray: [Recording] = [tempRecording1, tempRecording2]
        tempRecording1.name = "3"
        tempRecording2.name = "4"
        let recordingArray2: [Recording] = [tempRecording1, tempRecording2]
        
        let tempFolder1 = Folder(name: "1", parent: rootFolder, folders: dummyArray, recordings: recordingArray, shown: false)
        let tempFolder2 = Folder(name: "2", parent: rootFolder, folders: dummyArray, recordings: recordingArray2, shown: false)
        let folderArray: [Folder] = [tempFolder1, tempFolder2]
     
        rootFolder.folders = folderArray
        rootFolder.recordings = recordingArray
        currentFolder = rootFolder
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
   
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        folderCount = 0
        // TODO
        if(currentFolder.parent == nil){ //root folder
            return currentFolder.folders!.count + currentFolder.recordings!.count
        }
        
        if(currentFolder.recordings == nil){ //Folder contains no recordings
            return currentFolder.folders!.count
        }
        
        if(currentFolder.folders == nil){ //Folder contains no folders
            return currentFolder.recordings!.count
        }
        
        return currentFolder.folders!.count + currentFolder.recordings!.count + 1 //Includes parent so you can navigate back
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //If the folder has a parent, include it as the top row so you can navigate back
        
        if(indexPath.row == 0 && currentFolder.parent != nil){
            
            // Table view cells are reused and should be dequeued using a cell identifer
            
            let cellIdentifier = "ArchiveFolderTableViewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArchiveFolderTableViewCell
            
            // Fetches the appropriate data for the data source layout
            
            let title = currentFolder.parent!.name
            let folder = currentFolder.parent!
            
            cell.folderLabel.text = title + " (Return)"
            cell.folder = folder
            
            return cell
        }
        
        // Add folder rows if necessary
        
        if(folderCount < currentFolder.folders?.count){
            
            
            // Table view cells are reused and should be dequeued using a cell identifer
            
            let cellIdentifier = "ArchiveFolderTableViewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArchiveFolderTableViewCell
            
            // Fetches the appropriate data for the data source layout
            
            let title = currentFolder.folders![folderCount].name
            let folder = currentFolder.folders![folderCount]
            
            cell.folderLabel.text = title
            cell.folder = folder
            
            folderCount++
            
            return cell
        
        }
        
        // Add recordings rows if necessary
        // We want to use indexPath.row to get our recording array element, however we need to account for any folder rows that have been inserted so we subtract from indexPath the # of rows that we have created prior to this
        
        var adjustedRowIndex = indexPath.row - currentFolder.folders!.count
        if(currentFolder.parent != nil){
            
            adjustedRowIndex -= 1
        }
        
        // Table view cells are reused and should be dequeued using a cell identifer
        
        let cellIdentifier = "ArchiveTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArchiveTableViewCell
        
        // Fetches the appropriate data for the data source layout
        
        let title = currentFolder.recordings![adjustedRowIndex].name
        let recording = currentFolder.recordings![adjustedRowIndex]
        
        cell.titleLabel.text = title
        cell.recording = recording
        
        return cell
        
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
            /*
            selectedFolder.shown = true
            var indexPaths: [NSIndexPath]
            
                
            for folder in selectedFolder.folders! {
                
                tableView.insertRowsAtIndexPaths(_ indexPaths: [NSIndexPath],
                    withRowAnimation animation: UITableViewRowAnimation)
            }
            
            
            */
            
        }
        
        return indexPath
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
































