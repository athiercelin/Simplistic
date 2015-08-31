//
//  InterfaceController+WCSessionDelegate.swift
//  Simplistic
//
//  Created by Arnaud Thiercelin on 8/11/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

extension InterfaceController: WCSessionDelegate {
	
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
		
	
		
	}
	
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
		
	}
	
	func session(session: WCSession, didReceiveMessageData messageData: NSData) {
		
	}
	
	func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
		
	}
	
}