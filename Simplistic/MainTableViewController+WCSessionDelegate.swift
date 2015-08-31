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

extension MainTableViewController :WCSessionDelegate  {

	func sessionReachabilityDidChange(session: WCSession) {
		
	}
	
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
		
	}
	
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
		
		if message["command"] as! String == "GET_LIST" {
			// replys
			
			do {
				try self.fetchedResultsController.performFetch()
				
				let resultArray = NSMutableArray()
				//				 memory problem here. when this block is over, it releases the answer object and crashes.
				
				for managedObject in self.fetchedResultsController.fetchedObjects! as! [NSManagedObject] {
					
					let dictionary = NSMutableDictionary()
					
					dictionary.setObject(managedObject.valueForKey("label")!, forKey: "label")
					dictionary.setObject(managedObject.valueForKey("done")!, forKey: "done")
//					let managedObj = managedObject as! NSManagedObject
//					let attributes = managedObj.entity.attributesByName as NSDictionary
//					let keys = attributes.allKeys as! [String]
//					let dictionary = managedObj.dictionaryWithValuesForKeys(keys)
//					
					resultArray.addObject(dictionary)
				}
				replyHandler(["result":resultArray.copy()])
			} catch {
				//Error handling
			}
			
		} else if message["command"] as! String == "SET_DONE" {
			
			let itemPosition = message["itemId"] as! Int
			let itemLabel = message["itemLabel"] as! String
			let newDoneStatus = message["newDoneStatus"] as! Bool
			do {
				let item = try self.getItemFromCoreData(withPosition:itemPosition)
				
				if item != nil {
					let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: itemPosition, inSection: 0)) as! MainTableViewCell
					
					if (item.valueForKey("label") as! String != itemLabel) {
						NSLog("Wrong Item at %d. Expected [%@], had [%@]", itemPosition, itemLabel, item.valueForKey("label") as! String)
					} else {
						
						item.setValue(newDoneStatus, forKey: "done")
						item.setValue(NSDate(), forKey: "done_date")
						
						do {
							try self.managedObjectContext.save()
						} catch {
							
						}
						
						if newDoneStatus == true {
							cell.backgroundColor = self.cellDoneBackGroundColor
							cell.itemLabel.textColor = self.cellDoneTextcolor
							cell.itemField.textColor = self.cellDoneTextcolor
						} else {
							cell.backgroundColor = self.cellUnDoneBackGroundColor
							cell.itemLabel.textColor = self.cellUnDoneTextColor
							cell.itemField.textColor = self.cellUnDoneTextColor
						}
					}
					replyHandler(["Exec": true])
				}
			} catch {
				// Error handling
			}
		} else if message["command"] as! String == "DELETE_DONE" {
			self.removeDoneItems()
			replyHandler(["Exec" : true])
		}
		
	}

	func session(session: WCSession, didReceiveMessageData messageData: NSData) {
		
	}
	
	func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
		
	}
	
}