//
//  ReachabilityConnection.swift
//  Pi Monitor
//
//  Created by Kayron Cabral on 25/04/16.
//  Copyright © 2016 Pandora Technology. All rights reserved.
//

import UIKit
import Reachability

@objc protocol ReachabilityDelegate: class {
    optional func onWiFiReachable(reach: Reachability)
    optional func onWiFiUnreachable(reach: Reachability)
    optional func onServerReachable(reach: Reachability)
    optional func onServerUnreachable(reach: Reachability)
    optional func onInternetReachable(reach: Reachability)
    optional func onInternetUnreachable(reach: Reachability)
}

class ReachabilityConnection {
    
    var delegate: ReachabilityDelegate?
    var wiFiReach: Reachability?
    var serverReach: Reachability?
    var internetReach: Reachability?
    
    init(){
        initWiFiReach()
        initInternetReach()
        initServerReach()
    }
    
    func initWiFiReach() {
        wiFiReach = Reachability.reachabilityForLocalWiFi()
        wiFiReach!.reachableOnWWAN = false
        
        wiFiReach!.reachableBlock = {(let reach: Reachability!) -> Void in
            if reach.isReachable() {
                self.delegate?.onWiFiReachable!(reach)
            }
        }
        
        wiFiReach!.unreachableBlock = {(let reach: Reachability!) -> Void in
            if !reach.isReachable() {
                self.delegate?.onWiFiUnreachable!(reach)
            }
        }
        
        wiFiReach!.startNotifier()
    }

    func initInternetReach() {
        internetReach = Reachability.reachabilityForInternetConnection()
        
        internetReach!.reachableBlock = {(let reach: Reachability!) -> Void in
            if reach.isReachable() {
                self.delegate?.onInternetReachable!(reach)
            }
        }
        
        internetReach!.unreachableBlock = {(let reach: Reachability!) -> Void in
            if !reach.isReachable() {
                self.delegate?.onInternetUnreachable!(reach)
            }
        }
        
        internetReach!.startNotifier()
    }
    
    func initServerReach() {
        serverReach = Reachability(hostName: "\(URL.IP)")
        
        serverReach!.reachableBlock = {(let reach: Reachability!) -> Void in
            if reach.isReachable() {
                self.delegate?.onServerReachable!(reach)
            }
        }
        
        serverReach!.unreachableBlock = {(let reach: Reachability!) -> Void in
            if !reach.isReachable() {
                self.delegate?.onServerUnreachable!(reach)
            }
        }
        
        serverReach!.startNotifier()
    }
}