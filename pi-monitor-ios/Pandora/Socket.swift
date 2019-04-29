//
//  Socket.swift
//  Pandora
//
//  Created by Kayron Cabral on 03/12/15.
//  Copyright © 2015 Pandora Technology. All rights reserved.
//

import Foundation
import SocketIOClientSwift

@objc public protocol SocketDelegate: class {
    optional func onECG(data: Float)
    optional func onSPO2(data: Float)
    optional func onAirflow(data: Float)
    optional func onEMG(data: Float)
    optional func onHeartRate(data: Int)
    optional func onTemperature(data: Float)
    optional func onBloodPressure(systolic: Int, diastolic: Int)
    optional func onPosition(data: Int)
}

class Socket {
    
    static var delegate: SocketDelegate?
    
    private static var SOCKET_ECG: SocketIOClient!
    private static var SOCKET_SPO2: SocketIOClient!
    private static var SOCKET_AIRFLOW: SocketIOClient!
    private static var SOCKET_EMG: SocketIOClient!
    private static var SOCKET_TEMPERATURE: SocketIOClient!
    private static var SOCKET_BLOOD_PRESSURE: SocketIOClient!
    private static var SOCKET_POSITION: SocketIOClient!
    
    static var ECG_PORT = 0
    static var SPO2_PORT = 0
    static var AIRFLOW_PORT = 0
    static var EMG_PORT = 0
    static var TEMPERATURE_PORT = 0
    static var BLOOD_PRESSURE_PORT = 0
    static var POSITION_PORT = 0
    
    class func connect() {
        
        SOCKET_ECG = SocketIOClient(socketURL: NSURL(string: "http://\(URL.IP):\(Socket.ECG_PORT)")!, options: [.Log(false)])
        SOCKET_SPO2 = SocketIOClient(socketURL: NSURL(string: "http://\(URL.IP):\(Socket.SPO2_PORT)")!, options: [.Log(false)])
        SOCKET_AIRFLOW = SocketIOClient(socketURL: NSURL(string: "http://\(URL.IP):\(Socket.AIRFLOW_PORT)")!, options: [.Log(false)])
        SOCKET_EMG = SocketIOClient(socketURL: NSURL(string: "http://\(URL.IP):\(Socket.EMG_PORT)")!, options: [.Log(false)])
        SOCKET_TEMPERATURE = SocketIOClient(socketURL: NSURL(string: "http://\(URL.IP):\(Socket.TEMPERATURE_PORT)")!, options: [.Log(false)])
        SOCKET_BLOOD_PRESSURE = SocketIOClient(socketURL: NSURL(string: "http://\(URL.IP):\(Socket.BLOOD_PRESSURE_PORT)")!, options: [.Log(false)])
        SOCKET_POSITION = SocketIOClient(socketURL: NSURL(string: "http://\(URL.IP):\(Socket.POSITION_PORT)")!, options: [.Log(false)])
        
        SOCKET_ECG.on("ecg") { (data) -> Void in
            if let ecg = Float(String(data.0[0])) {
                self.delegate?.onECG!(ecg)
            }
        }
        
        SOCKET_EMG.on("emg") { (data) -> Void in
            if let emg = Float(String(data.0[0])) {
                self.delegate?.onEMG!(emg)
            }
        }

        SOCKET_SPO2.on("spo2") { (data) -> Void in
            if let spo2 = Float(String(data.0[0])) {
                self.delegate?.onSPO2!(spo2)
            }
        }
        
        SOCKET_ECG.on("bpm") { (data) -> Void in
            if let heartRate = Int(String(data.0[0])) {
                self.delegate?.onHeartRate!(heartRate)
            }
        }
        
        SOCKET_TEMPERATURE.on("temperature") { (data) -> Void in
            if let temperature = Float(String(data.0[0])) {
                self.delegate?.onTemperature!(temperature)
            }
        }
        
        SOCKET_AIRFLOW.on("airflow") { (data) -> Void in
            if let airflow = Float(String(data.0[0])) {
                self.delegate?.onAirflow!(airflow)
            }
        }

        SOCKET_POSITION.on("patientposition") { (data) -> Void in
            if let position = Int(String(data.0[0])) {
                self.delegate?.onPosition!(position)
            }
        }
        
        SOCKET_BLOOD_PRESSURE.on("bloodpressure") { (data) -> Void in
            if let pressure = data.0[0] as? String {
                let pressures = pressure.componentsSeparatedByString(",")
                let systolic = Int(pressures[0])!
                let diastolic = Int(pressures[1])!
                self.delegate?.onBloodPressure!(systolic, diastolic: diastolic)
            }
        }
        
        SOCKET_ECG.connect()
        SOCKET_SPO2.connect()
        SOCKET_AIRFLOW.connect()
        SOCKET_EMG.connect()
        SOCKET_TEMPERATURE.connect()
        SOCKET_BLOOD_PRESSURE.connect()
        SOCKET_POSITION.connect()
    }
    
    class func disconnect() {
        SOCKET_ECG.disconnect()
        SOCKET_SPO2.disconnect()
        SOCKET_AIRFLOW.disconnect()
        SOCKET_EMG.disconnect()
        SOCKET_TEMPERATURE.disconnect()
        SOCKET_BLOOD_PRESSURE.disconnect()
        SOCKET_POSITION.disconnect()
    }
    
}
    
