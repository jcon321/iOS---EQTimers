//
//  NewTimerViewController.swift
//  Timers
//
//  Created by Jordan Conner on 2/19/15.
//  Copyright (c) 2015 Jordan Conner. All rights reserved.
//

import UIKit

class NewTimerViewController: UIViewController {
    
    
    @IBOutlet weak var newTimerName: UITextField!
    @IBOutlet weak var newTimerAmount: UITextField!
    
    var newTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNew() {
        newTimer.name = newTimerName.text
        newTimer.seconds = newTimerAmount.text.toInt()!
        
        saveData()
        
        navigationController?.popViewControllerAnimated(true)
    }

    
    func saveData() {
        let fileMgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        let databasePath = docsDir.stringByAppendingPathComponent("timers.db");
        
        let timerDB = FMDatabase(path: databasePath)
        
        if timerDB.open() {
            let insertSQL = "INSERT INTO TIMERS (name, seconds) VALUES ('\(newTimer.name!)', '\(newTimer.seconds!)')"
            
            let result = timerDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
            
            if !result {
                println("Error: \(timerDB.lastErrorMessage())")
            }
        } else {
            println("Error: \(timerDB.lastErrorMessage())")
        }
    }
    
}