//
//  MainTableViewController+CloudKit.swift
//  Simplistic
//
//  Created by Arnaud Thiercelin on 8/3/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import Foundation
import CloudKit
import CoreData


// TODO: Finish this.
extension MainTableViewController {
	
	func getDataFromCloudKit () {
		
		let container = CKContainer.defaultContainer()
		let publicDatabase = container.publicCloudDatabase
		let ItemsType = "Items"
		
		let query = CKQuery(recordType: ItemsType, predicate: NSPredicate())
		
		publicDatabase.performQuery(query, inZoneWithID: nil) { (records, error) -> Void in
			
			guard error != nil else {
				NSLog("Error loading Data from cloudkit")
				// more error handling
				return
			}
			
			// Pulling data from coredata to compare.			
			do {
				try self.fetchedResultsController.performFetch()
			} catch {
				// Error handling
			}
			
			for record in records! {
				// We need to merge data with what we have locally.
				let recordLastModifDate: NSDate = record.valueForKey("last_modif_date") as! NSDate
				let recordCreationDate: NSDate = record.valueForKey("creation_date") as! NSDate
				let recordPosition = record["position"] as! Int
				let recordNewStatus = record["new"] as! Bool
				let recordLabel = record["label"] as! String
				let recordDoneDate: NSDate = record["done_date"] as! NSDate
				let recordDoneStatus = record["done"] as! Bool

				var foundItem = false
				
				for managedObject in self.fetchedResultsController.fetchedObjects! {
					let managedPosition = managedObject.valueForKey("position") as! Int
					let managedLabel = managedObject.valueForKey("label") as! String
					let managedNewStatus = managedObject.valueForKey("new") as! Bool
					let managedDoneStatus = managedObject.valueForKey("done") as! Bool
					let managedDoneDate = managedObject.valueForKey("done_date") as! NSDate
					let managedCreationDate = managedObject.valueForKey("creation_date") as! NSDate
					let managedModifDate = managedObject.valueForKey("last_modif_date") as! NSDate
					
					if managedObject.objectID.URIRepresentation().description == record.recordID.description {
						foundItem = true
						
						// test which data is the newest.
						
						let modifTimeInterval = recordLastModifDate.timeIntervalSinceDate(managedModifDate)
						
						if modifTimeInterval == 0 { // No change between cloudkit and coredata
							// nothing to be done here. leave it in case we want to add stats/diag.
						} else if modifTimeInterval > 0 { // Cloudkit was changed more recently
							// this is quick and dirty, best would be to find what changed and only touch that for bp reasons.
							managedObject.setValue(recordPosition, forKey: "position")
							managedObject.setValue(recordLabel, forKey: "label")
							managedObject.setValue(recordNewStatus, forKey: "new")
							managedObject.setValue(recordDoneStatus, forKey: "done")
							managedObject.setValue(recordDoneDate, forKey: "done_date")
							managedObject.setValue(recordCreationDate, forKey: "creation_date")
							managedObject.setValue(recordLastModifDate, forKey: "last_modif_date")
							
						} else { // CoreData was changed more recently
							
							
							record.setValue(managedPosition, forKey: "position")
							record["label"] = managedLabel
							record["new"] = managedNewStatus
							record["done"] = managedDoneStatus
							record["done_date"] = managedDoneDate
							record["creation_date"] = managedCreationDate
							record["last_modif_date"] = managedModifDate
							
						}
					}
				}
				
				if foundItem == false { // item exist in Cloudkit but not in CoreData.
					
				}
				
				// Now we need to do push what exist in coredata but not in cloudkit.
				
			}

			
			do {
				try self.managedObjectContext.save()
			} catch {
				// Error handling
			}

			
		}
	}
	
	func addRecordToCloudKit(managedObject: NSManagedObject) {
		let recordId = CKRecordID(recordName: managedObject.objectID.URIRepresentation().description)
		let newRecord = CKRecord(recordType: "Items", recordID: recordId)
		
		newRecord["position"] = managedObject.valueForKey("position") as! Int
		newRecord["label"] = managedObject.valueForKey("label")  as! String
		newRecord["new"] = managedObject.valueForKey("new") as! Bool
		newRecord["done"] = managedObject.valueForKey("done") as! Bool
		newRecord["done_date"] = managedObject.valueForKey("done_date") as! NSDate
		newRecord["creation_date"] = managedObject.valueForKey("creation_date") as! NSDate
		newRecord["last_modif_date"] = managedObject.valueForKey("last_modif_date") as! NSDate
		
		let container = CKContainer.defaultContainer()
		let publicDatabase = container.publicCloudDatabase
		
		
		publicDatabase.saveRecord(newRecord) { (record, error) -> Void in
			if error != nil {
				// failure
			} else {
				// success
			}
			
		}
	}
	
	func modifyRecordInCloudKit(managedObject: NSManagedObject, updateValueWithKeys keys:[String]) {
		let container = CKContainer.defaultContainer()
		let publicDatabase = container.publicCloudDatabase
		let recordId = CKRecordID(recordName: managedObject.objectID.URIRepresentation().description)
		
		publicDatabase.fetchRecordWithID(recordId) { (record, error) -> Void in
			if error != nil {
				// error handling
			} else {
				
				for key: String in keys {
					record!.setValue(managedObject.valueForKey(key), forKey: key)
				}
				
				
			}
		}
		
	}
	
}