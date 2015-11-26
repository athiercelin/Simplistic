//
//  InterfaceController.swift
//  Simplistic WatchKit Extension
//
//  Created by Arnaud Thiercelin on 6/26/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
	
	let cellUnDoneTextColor = UIColor(red: 201/255, green: 239/255, blue: 255/255, alpha: 1)
	let cellDoneTextcolor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
	
	@IBOutlet var mainTable: WKInterfaceTable!
	
	var session: WCSession? = nil
	
	override func awakeWithContext(context: AnyObject?) {
		super.awakeWithContext(context)
		
		// Configure interface objects here.
		
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		
		if WCSession.isSupported() {
			self.session = WCSession.defaultSession()
			self.session!.delegate = self
			self.session!.activateSession()
			self.useApplicationContext(self.session!.applicationContext)
		} else {
			//FIXME: implem here
		}
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
		let rowController = table.rowControllerAtIndex(rowIndex) as! ItemsRowController
		let itemId = rowIndex
		let itemLabel = rowController.labelString
		let doneStatus = rowController.doneStatus
		
		self.setDoneStatus(!doneStatus, forItemWithId: itemId, andLabel: itemLabel)
	}
	
	func setDoneStatus(doneStatus: Bool, forItemWithId itemId: Int, andLabel label: String) {
		NSLog("Setting Done on item %@ at position %d", label, itemId)

		
		let rowController = self.mainTable.rowControllerAtIndex(itemId) as! ItemsRowController
		
		rowController.doneStatus = doneStatus
		let attributedText = NSMutableAttributedString(string: rowController.labelString)
		
		if doneStatus == false {
			rowController.label.setAttributedText(attributedText)
			rowController.label.setTextColor(self.cellUnDoneTextColor)
		} else {
			attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, rowController.labelString.characters.count))
			
			rowController.label.setAttributedText(attributedText)
			rowController.label.setTextColor(self.cellDoneTextcolor)
		}
		self.setApplicationContext()
	}
	
	@IBAction func deleteDoneItems() {
		NSLog("Deleting Done Items")
		if self.session!.reachable {
			// Removed for now AT 2015-11
		}
	}
	
}
