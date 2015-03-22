//
//  DataViewController.swift
//  destiny
//
//  Created by becker on 3/10/15.
//  Copyright (c) 2015 becker. All rights reserved.
//
class CustomTableViewCell: UITableViewCell {
    @IBOutlet var planet: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var time: UILabel!
    var start = ""
    var itemsRequestDate = NSDate();
    var timer:NSTimer = NSTimer();
    var startTime = NSTimeInterval()
    
    func loadItem(#data: [String]) {
        if(data.count > 0 ){
            self.planet.text = data[0]
            self.location.text = data[1]
            self.type.text = data[2]
            self.time.text = data[3]
            var epochTime = NSTimeInterval(data[4].toInt()!)
            self.itemsRequestDate = NSDate(timeIntervalSince1970: epochTime)
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: aSelector, userInfo: nil, repeats: true)
            self.start = data.last!
        }
    }
    
    func updateTime(){
        var elapsedSeconds = NSDate().timeIntervalSinceDate(self.itemsRequestDate)
        var requestSecondsLapsed:Int = Int(1 * (elapsedSeconds))
        var time = self.start
        var now = NSDate()
        var timeInt:Int! = time.toInt()! - requestSecondsLapsed
        var date = now + timeInt.seconds
        let elapsedTimeSeconds = NSDate().timeIntervalSinceDate(date)
        let minutesLapsed = -1 * (elapsedTimeSeconds/60)
      
        self.time.text = "\(Int(minutesLapsed)) minutes"

    }
}

import UIKit
import Foundation
class DataViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    var items: [[String]] = []
    var itemsRequestDate = NSDate();
    var fireItems = [String: [AnyObject]]()
    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: AnyObject?
    @IBOutlet weak var tableView: UITableView!
    var refreshControl:UIRefreshControl!
    var myRootRef = Firebase(url:"https://dtimer.firebaseio.com/")
    
    override func viewDidLoad() {
        loadFromFirebase()
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        var nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let obj: AnyObject = dataObject {
            self.dataLabel!.text = "Public events"
        } else {
            self.dataLabel!.text = ""
        }
    }
    func loadFromFirebase(){
        myRootRef.observeEventType(.Value, withBlock: { snapshot in
            println(snapshot.children.allObjects)
            if (snapshot.children.allObjects.count > 0){
                self.fireItems.removeAll()
                
                var epoch = snapshot.children.allObjects[0] as FDataSnapshot
                
                var epochString = epoch.value as Int
                
                var epochTime = NSTimeInterval(epochString)
                self.itemsRequestDate = NSDate(timeIntervalSince1970: epochTime)
                var kids = snapshot.children.allObjects[1] as FDataSnapshot
                for rest in kids.children.allObjects as [FDataSnapshot] {
                    
                    var elapsedTimeSeconds = NSDate().timeIntervalSinceDate(self.itemsRequestDate)
                    var requestSecondsLapsed:Int = Int(1 * (elapsedTimeSeconds))
                    println(requestSecondsLapsed)
                    var planetName = ""
                    var eventList = [[String]]()
                    for child in rest.children.allObjects as [FDataSnapshot]{
                        if (child.key == "planetName"){
                            planetName = child.value as String
                        }
                        if(child.key == "mapLocations"){
                            for events in child.children.allObjects as [FDataSnapshot]{
                                // would love to use a dict here but fuck if i cant figure them out.
                                var event = [String]()
                                var types:[String] = events.value["eventTypes"] as [String]
                                
                                event.append(events.value["title"] as String)
                                event.append("|".join(types))
                                var time = events.value["start"] as String
                                var now = NSDate()
                                var timeInt:Int! = time.toInt()! - requestSecondsLapsed
                                var date = now + timeInt.seconds
                                let elapsedTimeSeconds = NSDate().timeIntervalSinceDate(date)
                                let minutesLapsed = -1 * (elapsedTimeSeconds/60)
                                event.append("\(Int(minutesLapsed)) minutes")
                                event.append("\(epochString)")
                                
                                event.append(time) //always last item for sorting
                                eventList.append(event)
                            }
                        }
                    }
                    self.fireItems[planetName as String] = eventList
                }
                self.buildItems()
                self.tableView.reloadData()
            }
        })
        
    }
    func buildItems(){
        self.items.removeAll()
        var tempItems = [[String]]()
        for (key, value) in self.fireItems {
            
            //
            println(key)
            println(value)
            if(value.count>0){
                for event in value {
                    println(event)
                    var mon = [key] + (event as [String])
                    tempItems.append(mon as [String])
                    //    var j = " ".join(event as [String])
                    //    self.items.append("\(key): \(j)")
                }
            }
        }
        self.items = tempItems.sorted{
            (arr1, arr2) -> Bool in
            arr1.last?.toInt() < arr2.last?.toInt()
        }
    }
    
    func refresh(sender:AnyObject)
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.loadFromFirebase()
            self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            self.refreshControl.endRefreshing()
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CustomTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as CustomTableViewCell
        
        //var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.loadItem(data: self.items[indexPath.row])
        //cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}

