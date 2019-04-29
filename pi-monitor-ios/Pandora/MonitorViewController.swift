//
//  MonitorViewController.swift
//  Pandora
//
//  Created by Kayron Cabral on 03/12/15.
//  Copyright © 2015 Pandora Technology. All rights reserved.
//

import UIKit

class MonitorViewController: UIViewController, SocketDelegate {

    let timelineSegue = "TimelineSegue"
    
    @IBOutlet weak var patientImageVIew: UIImageView!
    @IBOutlet weak var ECGWaveformView: Waveform!
    @IBOutlet weak var AirflowWaveformView: Waveform!
    @IBOutlet weak var EMGWaveforView: Waveform!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var spo2Label: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var positionImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Socket.delegate = self
        
        switch BedsViewController.bedSelected {
        case 1:
            patientImageVIew.image = UIImage(named: "patient 1")
            break
        case 2:
            patientImageVIew.image = UIImage(named: "patient 2")
            break
        default:
            patientImageVIew.image = UIImage(named: "patient 3")
            break
        }
        
        AppDelegate.monitorController = self
        
        settingButtonBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Socket.disconnect()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Socket.connect()
    }
    
    func onECG(data: Float) {
        dispatch_async(dispatch_get_main_queue(), {
            self.ECGWaveformView.data.append(Float(data))
        })
    }
    
    func onAirflow(data: Float) {
        dispatch_async(dispatch_get_main_queue(), {
            self.AirflowWaveformView.data.append(data)
        })
    }
    
    func onEMG(data: Float) {
        dispatch_async(dispatch_get_main_queue(), {
            self.EMGWaveforView.data.append(data)
        })
    }
    
    func onHeartRate(data: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            self.bpmLabel.text = String(data)
        })
    }
    
    func onSPO2(data: Float) {
        dispatch_async(dispatch_get_main_queue(), {
            self.spo2Label.text = String(data) + "%"
        })

    }
    
    func onBloodPressure(systolic: Int, diastolic: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            self.pressureLabel.text = String(systolic) + "/" + String(diastolic)
        })
    }
    
    func onTemperature(data: Float) {
        dispatch_async(dispatch_get_main_queue(), {
            self.temperatureLabel.text = String(data) + "ºC"
        })
    }
    
    func onPosition(data: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            switch PositionType(rawValue: data)! {
            case .Supine:
                self.positionImageView.image = UIImage(named: "position supine")
                break
            case .LeftLateralDecubitus:
                self.positionImageView.image = UIImage(named: "position left lateral recumbent")
                break
            case .RightLateralDecubitus:
                self.positionImageView.image = UIImage(named: "position right lateral recumbent")
                break
            case .Prone:
                self.positionImageView.image = UIImage(named: "position prone")
                break
            case .Stand:
                self.positionImageView.image = UIImage(named: "position stand")
                break
            }
        })

    }
 
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func settingButtonBar() {
        let button = UIButton(type: .System)
        button.setTitle("View Patient Record", forState: .Normal)
        button.frame = CGRectMake(0, 0, 267, 33)
        button.titleLabel?.font = UIFont.monospacedDigitSystemFontOfSize(16, weight: UIFontWeightMedium)
        button.backgroundColor = UIColor.greenyBlueColor()
        button.setTitleColor(UIColor.darkBlueGrey90Color(), forState: .Normal)
        button.layer.cornerRadius = button.bounds.height / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(MonitorViewController.historyOnClick), forControlEvents: .TouchUpInside)
        let barbuttonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barbuttonItem
    }
    
    func historyOnClick() {
        performSegueWithIdentifier(timelineSegue, sender: self)
    }
    
}