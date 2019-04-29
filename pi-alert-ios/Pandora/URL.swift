//
//  URL.swift
//  FightClub
//
//  Created by Kayron Cabral on 8/8/15.
//  Copyright © 2015 Guilherme Kenji Kodama. All rights reserved.
//

import UIKit

class URL: NSObject {
    
    //server
    static let IP = "45.56.69.128"
    static let PORT = "80"
    
    static let SIGNIN = "http://\(URL.IP):\(URL.PORT)/medical_staff/signin"
    static let SUBSCRIBE = "http://\(URL.IP):\(URL.PORT)/medical_staff/subscribe"
    static let UNSUBSCRIBE = "http://\(URL.IP):\(URL.PORT)/medical_staff/unsubscribe"
    static let BEDS = "http://\(URL.IP):\(URL.PORT)/beds"
    static let STOPHEART = "http://\(URL.IP):\(URL.PORT)/stopheart"
}
