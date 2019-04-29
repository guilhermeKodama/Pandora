//
//  Device.swift
//  Pi Monitor
//
//  Created by Kayron Cabral on 28/04/16.
//  Copyright © 2016 Pandora Technology. All rights reserved.
//

import Foundation

class Device {
    
    var id: Int!
    var ecg: [Float]?
    var bpm: [Int]?
    var airflow: [Float]?
    var emg: [Float]?
    var spo2: [Float]?
    var pressure: [Int]?
    var temperature: [Float]?
    var patientPosition: [Int]?

    init(id: Int?, ecg: [Float]?, bpm: [Int]?, airflow: [Float]?, emg: [Float]?, spo2: [Float]?, pressure: [Int]?, temperature: [Float]?, patientPosition: [Int]?){
        self.id = id
        self.ecg = ecg
        self.bpm = bpm
        self.airflow = airflow
        self.emg = emg
        self.spo2 = spo2
        self.pressure = pressure
        self.temperature = temperature
        self.patientPosition = patientPosition
    }
    
    init(data: AnyObject) {
        var succedParsing = false
        
        if  let id = data["device_id"] as? Int {
            self.id = id
            succedParsing = true
        }
        
        if  let ecg = data["ecg"] as? [Float] {
            self.ecg = ecg
            succedParsing = true
        }
        
        if  let bpm = data["bpm"] as? [Int] {
            self.bpm = bpm
            succedParsing = true
        }
        
        if  let airflow = data["airflow"] as? [Float] {
            self.airflow = airflow
            succedParsing = true
        }
        
        if  let emg = data["emg"] as? [Float] {
            self.emg = emg
            succedParsing = true
        }
        
        if  let spo2 = data["spo2"] as? [Float] {
            self.spo2 = spo2
            succedParsing = true
        }
        
        if  let pressure = data["pressure"] as? [Int] {
            self.pressure = pressure
            succedParsing = true
        }
        
        if  let temperature = data["temperature"] as? [Float] {
            self.temperature = temperature
            succedParsing = true
        }
        
        if  let patientPosition = data["patientPosition"] as? [Int] {
            self.patientPosition = patientPosition
            succedParsing = true
        }
        
        if(!succedParsing){
            print("Não foi possível fazer o parse do dicionario do Device")
        }
    }
    
}