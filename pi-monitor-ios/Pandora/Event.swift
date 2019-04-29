//
//  Timeline.swift
//  Pi Monitor
//
//  Created by Kayron Cabral on 28/04/16.
//  Copyright © 2016 Pandora Technology. All rights reserved.
//

import Foundation

import Foundation

class Event {
    
    var id: Int!
    var device: Device!
    
    init() {}
    
    init(id: Int, device: Device) {
        self.id = id
        self.device = device
    }
    
    init(data: AnyObject) {
        var succedParsing = false
        
        if  let id = data["id"] as? Int {
            self.id = id
            succedParsing = true
        }
        
        self.device = Device(data: data)
        
        if(!succedParsing){
            print("Não foi possível fazer o parse do dicionario da Timeline")
        }
    }
}