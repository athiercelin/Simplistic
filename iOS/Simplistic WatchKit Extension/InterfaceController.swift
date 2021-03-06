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
	
	override func awake(withContext context: AnyObject?) {
		super.awake(withContext: context)
		
		// Configure interface objects here.
		
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		
		if WCSession.isSupported() {
			self.session = WCSession.default()
			self.session!.delegate = self
			self.session!.activate()
			self.useApplicationContext(applicationContext: self.session!.applicationContext)
		} else {
			//FIXME: implem here
		}
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		let rowController = table.rowController(at: rowIndex) as! ItemsRowController
		let itemId = rowIndex
		let itemLabel = rowController.labelString
		let doneStatus = rowController.doneStatus
		
		self.setDoneStatus(doneStatus: !doneStatus, forItemWithId: itemId, andLabel: itemLabel)
	}
	
	func setDoneStatus(doneStatus: Bool, forItemWithId itemId: Int, andLabel label: String) {
		NSLog("Setting Done on item %@ at position %d", label, itemId)
		
		let rowController = self.mainTable.rowController(at: itemId) as! ItemsRowController
		
		rowController.doneStatus = doneStatus
		let attributedText = NSMutableAttributedString(string: rowController.labelString)
		
		if doneStatus == false {
			rowController.label.setAttributedText(attributedText)
			rowController.label.setTextColor(self.cellUnDoneTextColor)
		} else {
			attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, rowController.labelString.characters.count-1))
			
			rowController.label.setAttributedText(attributedText)
			rowController.label.setTextColor(self.cellDoneTextcolor)
		}
		self.setApplicationContext()
	}
	
	@IBAction func deleteDoneItems() {
		NSLog("Deleting Done Items")
		if self.session!.isReachable {
			// Removed for now AT 2015-11
		}
	}
	
}
