//
//  InterfaceController+ApplicationContext.swift
//  Simplistic
//
//  Created by Arnaud Thiercelin on 11/21/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

extension InterfaceController {
	
	func setApplicationContext() {

		var itemId = 0
		var newArray = [[String:AnyObject]]()
		while let rowController = self.mainTable.rowControllerAtIndex(itemId++) {
			let itemRowController = rowController as! ItemsRowController
			
			let newDictionary:[String:AnyObject] = ["label" : itemRowController.labelString,
				"done" : itemRowController.doneStatus]
			newArray.append(newDictionary)
		}
		do {
			try self.session!.updateApplicationContext(["result":newArray])
		} catch {
			NSLog("Error setting the application context")
		}
	}
	
	func useApplicationContext(applicationContext: [String : AnyObject]) {
		let arrayResults = applicationContext["result"]
		
		NSLog("data received: %@", arrayResults as! NSArray)
		
		let numberOfItems = arrayResults!.count
		
		self.mainTable.setNumberOfRows(numberOfItems, withRowType: "ItemsRow")
		
		let numberOfRows = self.mainTable.numberOfRows
		
		for var index = 0; index < numberOfRows; index++ {
			let dictionary = arrayResults?.objectAtIndex(index)
			let rowController = self.mainTable.rowControllerAtIndex(index) as! ItemsRowController
			let done = dictionary?.objectForKey("done") as! Bool
			let label = dictionary?.objectForKey("label") as? String
			
			rowController.doneStatus = done
			rowController.labelString = label!
			let attributedText = NSMutableAttributedString(string: label!)
			
			if done == false {
				rowController.label.setAttributedText(attributedText)
				rowController.label.setTextColor(self.cellUnDoneTextColor)
			} else {
				attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, label!.characters.count))
				
				rowController.label.setAttributedText(attributedText)
				rowController.label.setTextColor(self.cellDoneTextcolor)
			}
		}
	}
	
}