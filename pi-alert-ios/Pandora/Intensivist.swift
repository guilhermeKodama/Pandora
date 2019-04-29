//
//  Intensivist.swift
//  Pandora
//
//  Created by Kayron Cabral on 04/12/15.
//  Copyright © 2015 Pandora Technology. All rights reserved.
//

import UIKit

class Intensivist {
    
    private static let defaults = NSUserDefaults.standardUserDefaults()
    static var currentIntensivist: Intensivist!
    
    var cpf: String!
    var deviceToken: String!
    
    init(cpf: String, deviceToken: String) {
        self.cpf = cpf
        self.deviceToken = deviceToken
    }
    
}
