//
//  BedsViewController.swift
//  Pandora Monitor
//
//  Created by Kayron Cabral on 07/01/16.
//  Copyright © 2016 Pandora Technology. All rights reserved.
//

import UIKit
import iCarousel
import Reachability
import Alamofire

class BedsViewController: UIViewController, ReachabilityDelegate, iCarouselDelegate, iCarouselDataSource, UISearchBarDelegate {
    
    let monitorSegueIdentifier = "MonitorSegue"
    
    @IBOutlet weak var carouselVIew: iCarousel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    var beds = [Bed]() {
        didSet {
            let hasItems = beds.count > 0
            carouselVIew.hidden = !hasItems
            searchBar.hidden = !hasItems
            confirmButton.hidden = !hasItems
            messageLabel.hidden = hasItems
        }
    }
    static var bedSelected = 0
    var lastBedSelected = 0
    let reachConnection = ReachabilityConnection()
    var userSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reachConnection.delegate = self
        
        loadBeds()
        
        carouselVIew.type = .Rotary
        searchBar.backgroundImage = UIImage()
        
        if !beds.isEmpty {
            BedsViewController.bedSelected = beds.first!.id
        }

    }
    
    func onWiFiReachable(reach: Reachability) {
        print("WiFi Funcionou")
    }
    
    func onWiFiUnreachable(reach: Reachability) {
        print("WiFi Parou")
    }
    
    func onServerReachable(reach: Reachability) {
        print("Server Funcionou")
    }
    
    func onServerUnreachable(reach: Reachability) {
        print("Server Parou")
    }
    
    func onInternetReachable(reach: Reachability) {
        print("Internet Funcionou")
    }
    
    func onInternetUnreachable(reach: Reachability) {
        print("Internet Parou")
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return beds.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        
        let storyboard = UIStoryboard(name: "BedItem", bundle: nil)
        let bedItemViewController = storyboard.instantiateViewControllerWithIdentifier("BedItemIdentifier") as! BedItemViewController
        bedItemViewController.view.frame = CGRectMake(0, 0, 325, 325)

        bedItemViewController.titleLabel.text = String(beds[index].description)
        bedItemViewController.numberLabel.text = String(beds[index].id)
        
        if beds[index].hasConnection {
            bedItemViewController.view.backgroundColor = UIColor.whiteColor()
        } else {
            bedItemViewController.view.backgroundColor = Color.gray
        }
        
        if BedsViewController.bedSelected - 1 == index && beds[index].hasConnection {
            bedItemViewController.view.backgroundColor = Color.greenLight
        }
        
        return bedItemViewController.view
    }

    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        if !beds.isEmpty {
            BedsViewController.bedSelected = beds[carousel.currentItemIndex].id
        }
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        userSelected = true
    }
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel) {
        if userSelected {
            confirmOnClick(self)
            userSelected = false
        }
        carousel.reloadData()
    }
    
    @IBAction func confirmOnClick(sender: AnyObject) {
        
        let index = beds.indexOf({$0.id == BedsViewController.bedSelected})
        
        if beds[index!].hasConnection {
            let parameters = ["device_id": BedsViewController.bedSelected]
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            Alamofire.request(.POST, URL.DEVICE, parameters: parameters, encoding: .JSON).responseJSON(completionHandler: { (response) in
//                debugPrint(response)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if response.result.isSuccess {
                        let sensors = response.result.value as! [AnyObject]
                        for sensor in sensors {
                            switch SensorType(rawValue: sensor["sensor_id"] as! Int)! {
                            case .ECG:
                                Socket.ECG_PORT = sensor["output_port"] as! Int
                                break
                            case .SPO2:
                                Socket.SPO2_PORT = sensor["output_port"] as! Int
                                break
                            case .Airflow:
                                Socket.AIRFLOW_PORT = sensor["output_port"] as! Int
                                break
                            case .EMG:
                                Socket.EMG_PORT = sensor["output_port"] as! Int
                                break
                            case .Temperature:
                                Socket.TEMPERATURE_PORT = sensor["output_port"] as! Int
                                break
                            case .BloodPressure:
                                Socket.BLOOD_PRESSURE_PORT = sensor["output_port"] as! Int
                                break
                            case .PatientPosition:
                                Socket.POSITION_PORT = sensor["output_port"] as! Int
                                break
                            }
                        }
                        self.performSegueWithIdentifier(self.monitorSegueIdentifier, sender: nil)
                    }
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Change Bed"
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func refreshOnClick(sender: AnyObject) {
        loadBeds()
        print("Refresh button")
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let bed = searchBar.text
        if bed != ""{
            let bedNumber = Int(bed!)! - 1
            if beds.contains({$0.id == bedNumber}) {
                carouselVIew.scrollToItemAtIndex(bedNumber, animated: true)
                searchBar.text = ""
                searchBar.resignFirstResponder()
            }
        }
    }

    func loadBeds() {
        Alamofire.request(.GET, URL.BEDS + "/6969").responseJSON { (response) in
//            debugPrint(response)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if response.result.isSuccess {
                    let beds = response.result.value as! [AnyObject]
                    self.beds.removeAll()
                    for bed in beds {
                        let bed = Bed(data: bed)
                        self.beds.append(bed)
                    }
                    self.carouselVIew.reloadData()
                }
            })
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
}
