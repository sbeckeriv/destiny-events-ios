//
//  DataViewController.swift
//  destiny
//
//  Created by becker on 3/10/15.
//  Copyright (c) 2015 becker. All rights reserved.
//

import UIKit
import Foundation
class DataViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    var items: [String] = []
var fireItems = Dictionary<String, String>()
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
            self.fireItems.removeAll()
            var now : NSDate
            for rest in snapshot.children.allObjects as [FDataSnapshot] {
                let key_date : String = "2015-07-16 03:03:34"
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat =
                "yyyy-MM-dd HH:mm:ss"
                var date:NSDate! = dateFormatter.dateFromString(key_date)
                println(date)
                if (date != nil){
                    
                    let elapsedTimeSeconds = NSDate().timeIntervalSinceDate(date)
                    let minutesLapsed = -1 * (elapsedTimeSeconds/60)
                    println(minutesLapsed)
                }
                println(rest.value)
                self.fireItems[rest.key as String] = rest.value as? String
                println(self.fireItems)
                self.buildItems()
            }
            self.tableView.reloadData()
        })

    }
    func buildItems(){
        self.items.removeAll()
        for (key, value) in self.fireItems {                println(key)
            
            self.items.append("\(key) => \(value)")
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
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}

