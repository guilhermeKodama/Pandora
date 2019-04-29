//
//  SimulatorViewController.swift
//  Pandora Alert
//
//  Created by Kayron Cabral on 08/12/15.
//  Copyright © 2015 Pandora Technology. All rights reserved.
//

import UIKit
import Alamofire

class SimulatorViewController: UIViewController {

    let defaults = NSUserDefaults.standardUserDefaults()
    var token = String()
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        token = defaults.objectForKey("Token") as! String

    }

    @IBAction func stopHeartOnClick(sender: AnyObject) {
        let parameters = [
                            "token":"a4614044478b89fe46148067c3ef22d19eb63e44837be1aaea565bf0b90d5f5c",
                            "message": "Parada Cardíaca.O paciente necessita de assistência imediatamente"
                         ]
        
        Alamofire.request(.POST, URL.STOPHEART, parameters: parameters, encoding: .JSON).responseJSON { (response) in
            debugPrint(response)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if response.result.isSuccess {
                    self.messageLabel.text = "Parada cardíaca iniciada."
                }
            })
        }
    }
    
    @IBAction func closeOnClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
