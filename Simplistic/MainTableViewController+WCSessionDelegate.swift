//
//  MainTableViewController+WCSessionDelegate.swift
//  Simplistic
//
//  Created by Arnaud Thiercelin on 8/11/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import Foundation
import WatchConnectivity
import CoreData

extension MainTableViewController : WCSessionDelegate  {

	func sessionReachabilityDidChange(session: WCSession) {
		if session.reachable {
		}
	}
	
	func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
		self.useApplicationContext(applicationContext)
	}
	
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
		
	}
	
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
		
		if message["command"] as! String == "DELETE_DONE" {
			self.removeDoneItems()
			replyHandler(["Exec" : true])
		}
		
	}

	func session(session: WCSession, didReceiveMessageData messageData: NSData) {
		
	}
	
	func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
		
	}
	
}