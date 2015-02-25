//
//  PresetsViewController.swift
//  Timers
//
//  Created by Jordan Conner on 2/23/15.
//  Copyright (c) 2015 Jordan Conner. All rights reserved.
//

import UIKit

class PresetsViewController: UITableViewController {

    var databasePath = ""
    var myTimers:[Timer] = []
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myTimers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.textLabel?.text = "\(myTimers[indexPath.row].name!) - \(myTimers[indexPath.row].seconds!) Seconds"
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            deleteTimer(myTimers[indexPath.row].name!, seconds: myTimers[indexPath.row].seconds!)
            myTimers.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func findTimers() {
        let timerDB = FMDatabase(path: databasePath)
        
        if timerDB.open() {
            let querySQL = "SELECT * FROM timers"
            
            let results:FMResultSet? = timerDB.executeQuery(querySQL, withArgumentsInArray: nil)
            
            while (results?.next() == true) {
                var aTimer = Timer()
                aTimer.name = results?.stringForColumn("name")
                aTimer.seconds = results?.stringForColumn("seconds").toInt()
                myTimers.append(aTimer)
            }
            
            timerDB.close()
            
        } else {
            println("Error: \(timerDB.lastErrorMessage())")
        }
    }
    
    func deleteTimer(name: String, seconds: Int) {
        let timerDB = FMDatabase(path: databasePath)
        
        if timerDB.open() {
            let delSQL = "DELETE FROM timers WHERE name = '\(name)' AND seconds = \(seconds)"
            let results = timerDB.executeUpdate(delSQL, withArgumentsInArray: nil)
        } else {
            println("Error: \(timerDB.lastErrorMessage())")
        }
        timerDB.close()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileMgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.stringByAppendingPathComponent("timers.db");
        
        myTimers = []
        findTimers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
