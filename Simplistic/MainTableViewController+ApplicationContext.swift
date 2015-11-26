//
//  MainTableViewController+ApplicationContext.swift
//  Simplistic
//
//  Created by Arnaud Thiercelin on 11/20/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import Foundation
import CoreData
import WatchKit

extension MainTableViewController {
	
	func setApplicationContext() {
		guard session != nil else {
			return
		}
		
		do {
			try self.fetchedResultsController.performFetch()
			
			let resultArray = NSMutableArray()
			
			for managedObject in self.fetchedResultsController.fetchedObjects! as! [NSManagedObject] {
				
				let dictionary = NSMutableDictionary()
				
				dictionary.setObject(managedObject.valueForKey("label")!, forKey: "label")
				dictionary.setObject(managedObject.valueForKey("done")!, forKey: "done")
				resultArray.addObject(dictionary)
			}
			try self.session!.updateApplicationContext(["result": resultArray.copy()])
		} catch {
			//Error handling
			NSLog("Error setting the application context \(error)")
		}

	}
	
	func useApplicationContext(applicationContext: [String : AnyObject]) {
		// On the phone side, the only thing we monitor is the done status.
		let result = applicationContext["result"] as! [NSDictionary]
		
		var itemPosition = 0
		for item: NSDictionary in result {
			let itemLabel = item["label"] as! String
			let newDoneStatus = item["done"] as! Bool
			do {
				let item = try self.getItemFromCoreData(withPosition:itemPosition)
				
				if item != nil {
					let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: itemPosition, inSection: 0)) as! MainTableViewCell
					
					if (item.valueForKey("label") as! String == itemLabel) {
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
				}
			} catch {
				// Error handling
			}
			itemPosition++
		}
	}
}