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
		//TODO: hanlde this
	}
	
	func sessionReachabilityDidChange(session: WCSession) {
		//TODO: handle this too.
	}
	
	func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
		self.useApplicationContext(applicationContext)
	}

	
}