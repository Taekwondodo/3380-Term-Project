//
//  ArchiveFolderTableViewCell.swift
//  Note Recorder
//
//  Created by Michael Vedros on 11/17/15.
//  Copyright © 2015 Michael Vedros. All rights reserved.
//

import UIKit

class ArchiveFolderTableViewCell: UITableViewCell {

    var folder: Folder!
    var viewController: ArchiveTableViewController! // Referenced in expandFolder()
    @IBOutlet weak var folderLabel: UILabel!
    @IBOutlet weak var expandFolderButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        expandFolderButton.hidden = true
        expandFolderButton.addTarget(self, action: "expandFolder", forControlEvents: .TouchDown)
    }
    
    func expandFolder(){
        
        viewController.currentFolder = folder
        viewController.tableView.reloadData()
    }
    
/*
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
*/

}
