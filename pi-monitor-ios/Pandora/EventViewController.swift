//
//  EventViewController.swift
//  Pi Monitor
//
//  Created by Kayron Cabral on 28/04/16.
//  Copyright © 2016 Pandora Technology. All rights reserved.
//

import UIKit

class EventViewController: UIViewController, WaveformDelegate {

    static var event: Event?
    
    @IBOutlet weak var ECGWaveformView: Waveform!
    @IBOutlet weak var ecgLabel: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var spo2Label: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var xMarkerConstraint: NSLayoutConstraint!
    
    private var ecgData = EventViewController.event!.device.ecg!
    private var airflowData = EventViewController.event!.device.airflow!
    private var emgData = EventViewController.event!.device.emg!
    private var bpmData = EventViewController.event!.device.bpm!
    private var spo2Data = EventViewController.event!.device.spo2!
    private var temperatureData = EventViewController.event!.device.temperature!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ECGWaveformView.delegate = self
        initialize()
        reloadData(0, xPoint: CGFloat(0))
    }
    
    func onTouchMoved(position: Int, xPoint: CGFloat) {
        reloadData(position, xPoint: xPoint)
    }
    
    func reloadData(position: Int, xPoint: CGFloat) {
        bpmLabel.text = String(bpmData[position]) + " bpm"
        spo2Label.text = String(spo2Data[position])
        temperatureLabel.text = String(temperatureData[position]) + " ºC"
        ecgLabel.text = String(ecgData[position])
        xMarkerConstraint.constant = xPoint
    }
    
    
    /*
     Inicializa os Waveforms
     */
    func initialize() {
        ECGWaveformView.layer.borderColor = UIColor.greenyBlueColor().CGColor
        ECGWaveformView.isStreaming = false
        ECGWaveformView.data = ecgData
        ECGWaveformView.maxValueMilivolts = maxValue(ecgData)
    }
    
    /*
     Retorna o o maior valor absoluto de um array de dados
     */
    func maxValue(data: [Float]) -> CGFloat {
        let absMax = abs(data.maxElement()!)
        let absMin = abs(data.minElement()!)
        return absMax > absMin ? CGFloat(absMax + 0.5) : CGFloat(absMin + 0.5)
    }
    
    
}
