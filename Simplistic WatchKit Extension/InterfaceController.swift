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

	@IBOutlet var mainTable: WKInterfaceTable!
	@IBOutlet var noItemsLabel: WKInterfaceLabel!
	@IBOutlet var noDataLinkLabel: WKInterfaceLabel!
	
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

			self.mainTable.setHidden(false)

			if self.session!.reachable {
				self.noItemsLabel.setHidden(true)
				
				self.getFreshItemsList()
				self.noDataLinkLabel.setHidden(true)
			} else {
				self.noItemsLabel.setHidden(true)
				self.noDataLinkLabel.setHidden(false)
			}
			
		} else {
			
			self.mainTable.setHidden(true)
			self.noItemsLabel.setHidden(true)
			self.noDataLinkLabel.setHidden(false)
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
	
	func getFreshItemsList () {

		NSLog("Getting Fresh Items List")
		if self.session!.reachable {
			NSLog("Session is Reachable, sending GET_LIST")
			self.session!.sendMessage(["command":"GET_LIST"],
				replyHandler: { (message: [String : AnyObject]) -> Void in
					
					let arrayResults = message["result"]
					
					NSLog("data received: %@", arrayResults as! NSArray)
					
					let numberOfItems = arrayResults!.count
					
					if numberOfItems == 0 {
						self.mainTable.setHidden(true)
						self.noItemsLabel.setHidden(false)
					} else {
						self.mainTable.setHidden(false)
						self.noItemsLabel.setHidden(true)
					}
					
					
					self.mainTable.setNumberOfRows(numberOfItems, withRowType: "ItemsRow")
					
					let numberOfRows = self.mainTable.numberOfRows
					
					for var index = 0; index < numberOfRows; index++ {
						let dictionary = arrayResults?.objectAtIndex(index)
						let rowController = self.mainTable.rowControllerAtIndex(index) as! ItemsRowController
						let done = dictionary?.objectForKey("done") as! Bool
						
						rowController.doneStatus = done
						rowController.labelString = dictionary?.objectForKey("label") as! String
						rowController.label.setText(dictionary?.objectForKey("label") as? String)
						if done == false {
							rowController.label.setTextColor(UIColor.greenColor())
						} else {
							rowController.label.setTextColor(UIColor.redColor())
						}
						
						
					}
					
					
				},
				errorHandler: { (error: NSError) -> Void in
					NSLog("Error in GetList %@", error)
			})
		}
	}
	
	func setDoneStatus(doneStatus: Bool, forItemWithId itemId: Int, andLabel label: String) {
		
		
		NSLog("Setting Done on item %@ at position %d", label, itemId)
		if self.session!.reachable {
			NSLog("Session is Reachable, sending SET_DONE")
			self.session!.sendMessage(["command":"SET_DONE", "itemId" : itemId, "itemLabel" : label, "newDoneStatus" : doneStatus],
				replyHandler: { (message: [String : AnyObject]) -> Void in
					
					let rowController = self.mainTable.rowControllerAtIndex(itemId) as! ItemsRowController
					
					rowController.doneStatus = doneStatus
					if doneStatus == false {
						rowController.label.setTextColor(UIColor.greenColor())
					} else {
						rowController.label.setTextColor(UIColor.redColor())
					}
			},
				errorHandler: { (error:NSError) -> Void in
					NSLog("Error in setDone Status %@", error)
			})
		}
	}
	
	@IBAction func deleteDoneItems() {
		NSLog("Deleting Done Items")
		if self.session!.reachable {
			NSLog("Session is Reachable, sending DELETE_DONE")
			self.session!.sendMessage(["command":"DELETE_DONE"],
				replyHandler: { (message: [String : AnyObject]) -> Void in

						self.getFreshItemsList()
				},
				errorHandler: { (error:NSError) -> Void in
					NSLog("Error in setDone Status %@", error)
			})
		}
	}
	
}
