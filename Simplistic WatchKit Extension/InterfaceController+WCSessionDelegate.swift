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
	
	func sessionWatchStateDidChange(session: WCSession) {
		
	}
	
	func sessionReachabilityDidChange(session: WCSession) {
		
	}
	
	func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
//		self.session!.sendMessage(["command":"GET_LIST"],
//			replyHandler: { (message: [String : AnyObject]) -> Void in
		
		self.useApplicationContext(applicationContext)
//			},
//			errorHandler: { (error: NSError) -> Void in
//				NSLog("Error in GetList %@", error)
//		})
	}
	
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
		
	
		
	}
	
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
		
	}
	
	func session(session: WCSession, didReceiveMessageData messageData: NSData) {
		
	}
	
	func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
		
	}
	
}