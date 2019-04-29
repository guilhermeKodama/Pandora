//
//  TimelineViewController.swift
//  Pi Monitor
//
//  Created by Kayron Cabral on 27/04/16.
//  Copyright © 2016 Pandora Technology. All rights reserved.
//

import UIKit
import Alamofire

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let eventIdentifierTop = "EventIdentifierTop"
    let eventIdentifier = "EventIdentifier"
    let eventIdentifierBottom = "EventIdentifierBottom"
    let eventSegue = "EventSegue"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var events = [Event]() {
        didSet {
            let hasItems = events.count > 0
            tableView.hidden = !hasItems
            headerView.hidden = !hasItems
            messageLabel.hidden = hasItems
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        loadEvents()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var identifier = eventIdentifier
        
        if indexPath.row == 0 {
            identifier = eventIdentifierTop
        } else if indexPath.row == events.count - 1 {
            identifier = eventIdentifierBottom
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! EventCell
        
        return cell
    }
    
    func loadEvents() {
        let bedId = BedsViewController.bedSelected
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.request(.GET, URL.TIMELINE + "/\(bedId)").responseJSON { (response) in
//            debugPrint(response.result.value)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if response.result.isSuccess {
                    let events = response.result.value as! [AnyObject]
                    self.events.removeAll()
                    for event in events {
                        let event = Event(data: event)
                        self.events.append(event)
                    }
                    self.tableView.reloadData()
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        EventViewController.event = events[indexPath.row]
        performSegueWithIdentifier(eventSegue, sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}