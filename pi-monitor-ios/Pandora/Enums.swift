//
//  Enums.swift
//  Pi Monitor
//
//  Created by Kayron Cabral on 23/04/16.
//  Copyright © 2016 Pandora Technology. All rights reserved.
//

import Foundation

enum PositionType: Int {
    case Supine = 1
    case LeftLateralDecubitus
    case RightLateralDecubitus
    case Prone
    case Stand
}

enum SensorType: Int {
    case ECG = 1
    case SPO2
    case Airflow
    case EMG
    case Temperature
    case BloodPressure
    case PatientPosition
}