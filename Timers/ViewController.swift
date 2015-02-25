//
//  ViewController.swift
//  Timers
//
//  Created by Jordan Conner on 2/16/15.
//  Copyright (c) 2015 Jordan Conner. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate {
    
    var databasePath = ""
    
    var myTimers:[Timer] = []
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var myPicker: UIPickerView!
    
    var startTime = NSTimeInterval()
    var currentTime = NSTimeInterval()
    var timer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPicker.delegate = self
        myPicker.dataSource = self

        initDatabase()
    }
    
    override func viewWillAppear(animated: Bool) {
        myTimers = []
        findTimers()
        myPicker.reloadAllComponents()
    }
    
    func updateTime() {
        if currentTime != 0 {
        startTime--
        currentTime = startTime
        let hours = UInt8(currentTime / 3600)
        currentTime -= (NSTimeInterval(hours) * 3600)
        let minutes = UInt8(currentTime / 60)
        currentTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(currentTime)
        
        let strHours = hours > 9 ? String(hours):"0" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        
        labelTimer.text = "\(strHours):\(strMinutes):\(strSeconds)"
        } else {
            timer.invalidate()
            labelTimer.textColor = UIColor.redColor()
            labelTimer.text = "Expired!"
        }
    }
    
    func initDatabase() {
        let fileMgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        databasePath = docsDir.stringByAppendingPathComponent("timers.db");
        
        if !fileMgr.fileExistsAtPath(databasePath) {
            let timerDB = FMDatabase(path: databasePath)
            
            if timerDB == nil {
                println("Error: \(timerDB.lastErrorMessage())")
            }
            
            if timerDB.open() {
                let createTableStmt = "CREATE TABLE IF NOT EXISTS timers(ID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, seconds TEXT)"
                if !timerDB.executeStatements(createTableStmt) {
                    println("Error: \(timerDB.lastErrorMessage())")
                }
                timerDB.close()
            } else {
                println("Error: \(timerDB.lastErrorMessage())")
            }
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myTimers.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return myTimers[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timer.invalidate()
        labelTimer.textColor = UIColor.blackColor()
        labelTimer.text = "00:00:00"
        startTime = NSTimeInterval(myTimers[row].seconds!)
        currentTime = startTime
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        labelName.text = myTimers[row].name!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

