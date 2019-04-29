//
//  Bed.swift
//  Pandora
//
//  Created by Kayron Cabral on 03/12/15.
//  Copyright © 2015 Pandora Technology. All rights reserved.
//

import Foundation

class Bed {

    var id: Int!
    var description: String!
    var hasSubscription = false
    var hasConnection = false
    
    init() {}
    
    init(id: Int, description: String, hasSubscription: Bool, hasConnection: Bool) {
        self.id = id
        self.description = description
        self.hasSubscription = hasSubscription
        self.hasConnection = hasConnection
    }
    
    init(data: AnyObject) {
        var succedParsing = false
        
        if  let id = data["bed_id"] as? Int {
            self.id = id
            succedParsing = true
        }
        
        if  let description = data["bed_description"] as? String {
            self.description = description
            succedParsing = true
        }
        
        if  let hasSubscription = data["has_subscription"] as? Bool {
            self.hasSubscription = hasSubscription
            succedParsing = true
        }
        
        if  let hasConnection = data["has_connection"] as? Bool {
            self.hasConnection = hasConnection
            succedParsing = true
        }
        
        if(!succedParsing){
            print("Não foi possível fazer o parse do dicionario da Bed")
        }
    }
}
