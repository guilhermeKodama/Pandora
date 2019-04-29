//
//  BedsViewController.swift
//  Pandora
//
//  Created by Kayron Cabral on 01/12/15.
//  Copyright © 2015 Pandora Technology. All rights reserved.
//

import UIKit
import Alamofire

class BedsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!

    let defaults = NSUserDefaults.standardUserDefaults()
    let bedIdentifier = "BedPrototype"
    let refreshControl = UIRefreshControl()
    var alertViewController: AlertViewController = AlertViewController(nibName: "Alert", bundle: nil)
    var beds = [Bed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.tintColor = UIColor.blackColor()
        refreshControl.addTarget(self, action: #selector(BedsViewController.loadSubscriptions), forControlEvents: .ValueChanged)
        collectionView.addSubview(refreshControl)
        
        loadSubscriptions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bedIdentifier, forIndexPath: indexPath) as! BedCell
        
        if beds[indexPath.row].hasSubscription {
            cell.userInteractionEnabled = true
            cell.title.text = beds[indexPath.row].description
            cell.number.text = String(beds[indexPath.row].id)
            cell.check.image = UIImage(named: "check white")
            cell.background.backgroundColor = Color.green
        } else if !beds[indexPath.row].hasConnection {
            cell.userInteractionEnabled = false
            cell.title.text = beds[indexPath.row].description
            cell.number.text = String(beds[indexPath.row].id)
            cell.check.image = UIImage(named: "check")
            cell.background.backgroundColor = UIColor.lightGrayColor()
        } else {
            cell.userInteractionEnabled = true
            cell.title.text = beds[indexPath.row].description
            cell.number.text = String(beds[indexPath.row].id)
            cell.check.image = UIImage(named: "check")
            cell.background.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
 
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        checkSubscription(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        checkSubscription(indexPath)
    }
    
    @IBAction func logoutOnClick(sender: AnyObject) {
        defaults.removeObjectForKey("CPF")
        beds.removeAll()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func checkSubscription(indexPath: NSIndexPath) {
        let parameters = [
            "bed_id": "\(beds[indexPath.row].id)",
            "cpf": "\(Intensivist.currentIntensivist.cpf)"]

        if !beds[indexPath.row].hasSubscription {
            Alamofire.request(.POST, URL.SUBSCRIBE, parameters: parameters, encoding: .JSON).responseJSON(completionHandler: { (response) in
                debugPrint(response)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if response.result.isSuccess {
                        self.beds[indexPath.row].hasSubscription = true
                        self.collectionView.reloadData()
                    }
                })
            })
        } else {
            Alamofire.request(.POST, URL.UNSUBSCRIBE, parameters: parameters, encoding: .JSON).responseJSON(completionHandler: { (response) in
                debugPrint(response)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if response.result.isSuccess {
                        self.beds[indexPath.row].hasSubscription = false
                        self.collectionView.reloadData()
                    }
                })
            })
        }
    }
    
    
    
    func loadSubscriptions() {
        Alamofire.request(.GET, URL.BEDS + "/6969" + "/\(Intensivist.currentIntensivist.cpf)").responseJSON { (response) in
            debugPrint(response)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if response.result.isSuccess {
                    let beds = response.result.value as! [AnyObject]
                    self.beds.removeAll()
                    for bed in beds {
                        let bed = Bed(data: bed)
                        self.beds.append(bed)
                    }
                    self.collectionView.reloadData()
                }
                self.refreshControl.endRefreshing()
            })
        }
    }
    
}
