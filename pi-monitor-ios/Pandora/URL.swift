//
//  URL.swift
//  FightClub
//
//  Created by Kayron Cabral on 8/8/15.
//  Copyright © 2015 Guilherme Kenji Kodama. All rights reserved.
//

import UIKit

class URL {
    
    static let IP = "45.56.69.128"
    static let PORT = "80"

    static let DEVICE = "http://\(IP):\(URL.PORT)/device/connection/stablish"
    static let SUBSCRIPTIONS = "http://\(URL.IP):\(URL.PORT)/medical_staff/subscriptions"
    static let BEDS = "http://\(URL.IP):\(URL.PORT)/beds"
    static let TIMELINE = "http://\(URL.IP):\(URL.PORT)/timeline"
    
}
