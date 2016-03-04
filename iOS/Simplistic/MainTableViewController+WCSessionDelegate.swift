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
}