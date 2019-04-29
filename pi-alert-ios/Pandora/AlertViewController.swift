//
//  AlertViewController.swift
//  Pandora
//
//  Created by Kayron Cabral on 04/12/15.
//  Copyright © 2015 Pandora Technology. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    static var data = [NSObject : AnyObject]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bedLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.2)
        loadData(AlertViewController.data)
    }
    
    @IBAction func closeOnClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadData(userInfo: [NSObject : AnyObject]) {
        let notification = userInfo["aps"]
        let alert = notification!["alert"] as! String
        
        if let bedDescription = userInfo["bed_description"] as? String {
            bedLabel.text = bedDescription
        }
        
        let messages = alert.componentsSeparatedByString(".")
        
        if let title = messages.first {
            titleLabel.text = title
        }
        
        if let message = messages.last {
            messageLabel.text = message
        }
    }
}
