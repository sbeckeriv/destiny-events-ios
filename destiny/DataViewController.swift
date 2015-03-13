//
//  DataViewController.swift
//  destiny
//
//  Created by becker on 3/10/15.
//  Copyright (c) 2015 becker. All rights reserved.
//

import UIKit

class DataViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    var items: [String] = ["We", "Heart", "Swift"]
    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: AnyObject?
    @IBOutlet weak var tableView: UITableView!
    var refreshControl:UIRefreshControl!
    var myRootRef = Firebase(url:"https://dtimer.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myRootRef.observeEventType(.Value, withBlock: {
            snapshot in
            println("\(snapshot.key) -> \(snapshot.value)")
        })
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let obj: AnyObject = dataObject {
            self.dataLabel!.text = obj.description
        } else {
            self.dataLabel!.text = ""
        }
    }
    func refresh(sender:AnyObject)
    {
        dispatch_async(dispatch_get_main_queue()) {
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

