//
//  MainTableViewController.swift
//  Simplistic
//
//  Created by Arnaud Thiercelin on 6/26/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

class MainTableViewController: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
	
	let appDelegate = UIApplication.shared().delegate as! AppDelegate
	
	var cellUnDoneBackGroundColor = UIColor(red: 0.658102, green: 0.926204, blue: 0.673501, alpha: 1)
	var cellDoneBackGroundColor = UIColor(red: 0.926204, green: 0.658102, blue: 0.673501, alpha: 1)
	
	var cellUnDoneTextColor = UIColor(red: 0.00871759, green: 0.48909, blue: 0.000542229, alpha: 1)
	var cellDoneTextcolor = UIColor(red: 0.48909, green: 0.00871759, blue: 0.000542229, alpha: 1)
	
	var currentlyEditedCell: MainTableViewCell? = nil
	
	// MARK: CoreData Vars
	var _managedObjectContext: NSManagedObjectContext! = nil
	var managedObjectContext: NSManagedObjectContext {
		get {
			var token: dispatch_once_t = 0
			if _managedObjectContext == nil {
				dispatch_once(&token, { [unowned self] () -> Void in
					self._managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
					self._managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
					
					})
			}
			return _managedObjectContext
		}
	}
	var _managedObjectModel: NSManagedObjectModel! = nil
	var managedObjectModel: NSManagedObjectModel {
		get {
			var token: dispatch_once_t = 0
			if _managedObjectModel == nil {
				dispatch_once(&token, { [unowned self] () -> Void in
					let modelURL = NSBundle.mainBundle().URLForResource("SimplisticModel", withExtension: "momd")
					self._managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
					})
			}
			return _managedObjectModel
		}
	}
	
	var _persistentStoreCoordinator: NSPersistentStoreCoordinator! = nil
	var persistentStoreCoordinator: NSPersistentStoreCoordinator {
		get {
			var token: dispatch_once_t = 0
			if _persistentStoreCoordinator == nil {
				dispatch_once(&token, { [unowned self] () -> Void in
					self._persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
					})
			}
			return _persistentStoreCoordinator
		}
	}
	
	var fetchedResultsController: NSFetchedResultsController!? = nil
	
	var session: WCSession? = nil
	
	@IBOutlet var helpView: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.appDelegate.mainTableViewController = self
		
		self.setupColors()
		self.setupRecognizers()
		self.setupWatchKit()
		self.setupCoreDate()
	}
	
	func setupColors() {
		// TODO: This is a temporary theming of the app. Not sure if this will ever be used
		let theme = 1
		
		switch theme {
		case 1:
			self.cellUnDoneBackGroundColor = UIColor(red: 201/255, green: 239/255, blue: 255/255, alpha: 1)
			self.cellDoneBackGroundColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
			
			self.cellUnDoneTextColor = UIColor(red: 43/255, green: 115/255, blue: 252/255, alpha: 1)
			self.cellDoneTextcolor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
		default:
			self.cellUnDoneBackGroundColor = UIColor(red: 0.658102, green: 0.926204, blue: 0.673501, alpha: 1)
			self.cellDoneBackGroundColor = UIColor(red: 0.926204, green: 0.658102, blue: 0.673501, alpha: 1)
			
			self.cellUnDoneTextColor = UIColor(red: 0.00871759, green: 0.48909, blue: 0.000542229, alpha: 1)
			self.cellDoneTextcolor = UIColor(red: 0.48909, green: 0.00871759, blue: 0.000542229, alpha: 1)
		}
	}
	
	func setupRecognizers() {
		let addRecognizer = UILongPressGestureRecognizer(target: self, action: "addAction:")
		addRecognizer.minimumPressDuration = 0.25;
		//		delRecognizer.numberOfTapsRequired = 1;
		addRecognizer.numberOfTouchesRequired = 1;
		self.tableView.addGestureRecognizer(addRecognizer)
		
		let delRecognizer = UILongPressGestureRecognizer(target: self, action: "removeDoneItems:")
		delRecognizer.minimumPressDuration = 0.75;
		//		delRecognizer.numberOfTapsRequired = 1;
		delRecognizer.numberOfTouchesRequired = 2;
		self.tableView.addGestureRecognizer(delRecognizer)
	}
	
	func setupWatchKit() {
		if WCSession.isSupported() {
			self.session = WCSession.default()
			self.session!.delegate = self
			self.session!.activate()
		}
	}
	
	func setupCoreDate() {
		let applicationDocumentDirectory = FileManager.default().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
		let storeURL = applicationDocumentDirectory?.URLByAppendingPathComponent("SimplisticModel.sqllite")
		
		do {
			try self.persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
		} catch {
			//TODO: error handling
			NSLog("CORE DATA ERROR")
		}
		
		let fetchRequest = NSFetchRequest()
		let entity = NSEntityDescription.entity(forEntityName: "Items", in: self.managedObjectContext)
		
		fetchRequest.entity = entity
		fetchRequest.fetchBatchSize = 0
		
		let positionSortDescriptor = SortDescriptor(key: "position", ascending: true)
		let sortDescriptors = [positionSortDescriptor]
		
		fetchRequest.sortDescriptors = sortDescriptors
		
		self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "MainTableView")
		self.fetchedResultsController.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// load the data from coreData.
		do {
			try self.fetchedResultsController.performFetch()
			
			NSLog("%d", self.fetchedResultsController.fetchedObjects!.count)
			//cleanup of done for more than X time
			
			let timeDelay: Double = 24 * 3600 // 24hrs times 3600 seconds (1hr)
			let now = NSDate()
			var didChangeSomething = false
			
			for managedObject in self.fetchedResultsController.fetchedObjects! {
				
				let doneDate = managedObject.valueForKey("done_date")
				
				if doneDate != nil {
					let dateDelta = now.timeIntervalSinceDate(doneDate as! NSDate)
					let doneStatus = managedObject.valueForKey("done")!.boolValue
					let label = managedObject.valueForKey("label") as! String
					
					if doneStatus == true && dateDelta > timeDelay
						|| label.isEmpty == true
					{
						self.managedObjectContext.deleteObject(managedObject as! NSManagedObject)
						didChangeSomething = true;
					}
				}
			}
			if didChangeSomething == true {
				self.reorganizePositionIndex()
				do {
					try self.managedObjectContext.save()
				} catch {
					//TODO: error handling
				}
			}
		} catch {
			//TODO: Error handling
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.updateHelperViewVisibility()
		self.setApplicationContext()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		// TODO: This app is super lightweight but still.
	}
	
	// MARK: - Content Creation
	
	func addAction(recognizer: UILongPressGestureRecognizer) {
		if recognizer.state != UIGestureRecognizerState.began {
			return
		}
		
		// we test if something is currently being edited.
		if self.currentlyEditedCell != nil {
			// if it is not empty, we dont add another empty item.
			if self.currentlyEditedCell!.itemField.text!.isEmpty {
				
				let flashAnim = CATransform3DMakeScale(1, 1, 1)
				let currentColor = self.currentlyEditedCell?.layer.backgroundColor
				
				self.currentlyEditedCell?.layer.transform = flashAnim
				self.currentlyEditedCell?.layer.backgroundColor = UIColor(red: 1, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
				
				UIView.beginAnimations("flashAnim", context: nil)
				UIView.setAnimationDuration(0.8)
				self.currentlyEditedCell?.layer.transform = CATransform3DIdentity
				self.currentlyEditedCell?.layer.backgroundColor = currentColor
				UIView.commitAnimations()
				return;
			}
		}
		let itemsCount = self.fetchedResultsController.sections!.first!.numberOfObjects
		let entity = self.fetchedResultsController.fetchRequest.entity
		let newItem = NSEntityDescription.insertNewObjectForEntityForName(entity!.name!, inManagedObjectContext: self.managedObjectContext)
		newItem.setValue(true, forKey: "new")
		newItem.setValue(false, forKey: "done")
		newItem.setValue(itemsCount, forKey: "position")
		newItem.setValue(NSDate(), forKey: "done_date")
		newItem.setValue(NSDate(), forKey: "creation_date")
		newItem.setValue(NSDate(), forKey: "last_modif_date")
		newItem.setValue("", forKey: "label")
		
		// TODO: Push to cloudkit
		//	self.addRecordToCloudKit(newItem)
		
		do {
			try self.managedObjectContext.save()
		} catch {
			//TODO: error handling
		}
		
	}
	
	func removeDoneItems(recognizer: UITapGestureRecognizer) {
		self.removeDoneItems()
	}
	
	func removeDoneItems() {
		do {
			try self.fetchedResultsController.performFetch()
			for managedObject in self.fetchedResultsController.fetchedObjects! {
				
				let doneStatus = managedObject.valueForKey("done")!.boolValue
				
				if doneStatus == true {
					self.managedObjectContext.deleteObject(managedObject as! NSManagedObject)
					do {
						try self.managedObjectContext.save()
					} catch {
						//TODO: Error handling
					}
				}
			}
			self.reorganizePositionIndex()
			self.setApplicationContext()
		} catch {
			//TODO: Error handling
		}
	}
	
	func reorganizePositionIndex () {
		do {
			try self.fetchedResultsController.performFetch()
			var index = 0;
			for managedObject in self.fetchedResultsController.fetchedObjects! {
				managedObject.setValue(index++, forKey: "position")
			}
			do {
				try self.managedObjectContext.save()
			} catch {
				//TODO: Error handling
			}
			
			
		} catch {
			//TODO: Error handling
		}
	}
	
	// MARK: - View Updates
	
	func updateHelperViewVisibility () {
		
		let itemsCount = self.fetchedResultsController.sections!.first!.numberOfObjects
		
		if itemsCount == 0 {
			self.view.addSubview(self.helpView)
			self.helpView.translatesAutoresizingMaskIntoConstraints = false
			self.view.addConstraint(NSLayoutConstraint(item: self.helpView,
				attribute: .leading,
				relatedBy: .equal,
				toItem: self.view,
				attribute: .leading,
				multiplier: 1,
				constant: 0))
			self.view.addConstraint(NSLayoutConstraint(item: self.helpView,
				attribute: .trailing,
				relatedBy: .equal,
				toItem: self.view,
				attribute: .trailing,
				multiplier: 1,
				constant: 0))
			self.view.addConstraint(NSLayoutConstraint(item: self.helpView,
				attribute: .top,
				relatedBy: .equal,
				toItem: self.view,
				attribute: .top,
				multiplier: 1,
				constant: 0))
			self.view.addConstraint(NSLayoutConstraint(item: self.helpView,
				attribute: .bottom,
				relatedBy: .equal,
				toItem: self.view,
				attribute: .bottom,
				multiplier: 1,
				constant: 0))
			self.view.addConstraint(NSLayoutConstraint(item: self.helpView,
				attribute: .centerX,
				relatedBy: .equal,
				toItem: self.view,
				attribute: .centerX,
				multiplier: 1,
				constant: 0))
			self.view.addConstraint(NSLayoutConstraint(item: self.helpView,
				attribute: .centerY,
				relatedBy: .equal,
				toItem: self.view,
				attribute: .centerY,
				multiplier: 1,
				constant: 0))
		} else if self.helpView.superview != nil {
			self.helpView.removeFromSuperview()
		}
		
	}
	
	func configureCell(cell: MainTableViewCell, atIndexPath indexPath:NSIndexPath) {
		let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
		let label = object.valueForKey("label")?.description
		let done = object.valueForKey("done")?.boolValue
		let new = object.valueForKey("new")?.boolValue
		
		cell.itemField.text = label
		cell.itemLabel.text = label
		
		if done == true {
			let attributedText = NSMutableAttributedString(string: label!)
			
			attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, label!.characters.count))
			
			cell.backgroundColor = self.cellDoneBackGroundColor
			cell.itemLabel.textColor = self.cellDoneTextcolor
			cell.itemField.textColor = self.cellDoneTextcolor
			cell.itemLabel.attributedText = attributedText
		} else {
			cell.backgroundColor = self.cellUnDoneBackGroundColor
			cell.itemLabel.textColor = self.cellUnDoneTextColor
			cell.itemField.textColor = self.cellUnDoneTextColor
		}
		
		if new == true {
			cell.itemLabel.isHidden = true
			cell.itemField.isHidden = false
			cell.itemField.becomeFirstResponder()
			cell.itemField.delegate = self;
		}
		else {
			cell.itemLabel.isHidden = false
			cell.itemField.isHidden = true
		}
	}
	
	// MARK: - Table view data source
	
	// double check this one.
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section]
		
		return sectionInfo.numberOfObjects
	}
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath as IndexPath) as! MainTableViewCell
		
		self.configureCell(cell, atIndexPath: indexPath)
		
		return cell
	}
	
	
	// Override to support conditional editing of the table view.
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if self.currentlyEditedCell != nil {
			self.currentlyEditedCell?.itemField.resignFirstResponder()
		}
		
		do {
			let item = try self.getItemFromCoreData(withPosition: indexPath.row)
			let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! MainTableViewCell
			
			let itemDoneStatus: Bool = item.valueForKey("done") as! Bool
			let newDoneStatus = !itemDoneStatus
			item.setValue(newDoneStatus, forKey: "done")
			item.setValue(NSDate(), forKey: "done_date")
			
			do {
				try self.managedObjectContext.save()
				self.setApplicationContext()
			} catch {
				//TODO: Error handling here
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
		} catch {
			//TODO: Error handling
		}
		return
	}
	
	//MARK: TextField Delegate
	func textFieldDidBeginEditing(textField: UITextField) {
		
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		return true
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		let cell = textField.superview!.superview! as! MainTableViewCell
		let fieldValue = cell.itemField.text!
		let indexPath = self.tableView.indexPathForCell(cell)
		
		self.currentlyEditedCell = nil
		// sometimes indexPath is nil, I don't know why yet.
		if indexPath == nil {
			return
		}
		
		do {
			let managedItem = try self.getItemFromCoreData(withPosition: (indexPath?.row)!)
			
			// Sometimes we get a nil managed item and I don't know why yet - probabyl related to the position thingy.
			if managedItem == nil {
				return
			}
			
			if fieldValue.isEmpty {
				self.managedObjectContext.deleteObject(managedItem)
			} else {
				managedItem.setValue(fieldValue, forKey: "label")
				managedItem.setValue(false, forKey: "new")
				cell.itemLabel.text = fieldValue
				cell.itemField.hidden = true
				cell.itemLabel.hidden = false
			}
		} catch {
			//TODO:  Error handling here.
		}
		
		do {
			try self.managedObjectContext.save()
			self.setApplicationContext()
		} catch {
			//TODO: error handling
		}
	}
	
	
	//MARK: - Core Data + delegates
	// TODO: Need to change that position thingy, it's a bad idea.
	func getItemFromCoreData(withPosition position: Int) throws -> NSManagedObject!  {
		let fetchRequest = NSFetchRequest()
		let predicateTemplate = NSPredicate(format: "position == %d", position)
		
		fetchRequest.predicate = predicateTemplate
		let entity = NSEntityDescription.entityForName("Items", inManagedObjectContext: self.managedObjectContext)
		fetchRequest.entity = entity
		
		do {
			let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
			
			return results.first as! NSManagedObject!
		} catch {
			//TODO: error handling
		}
		return nil
	}
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		self.tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		//		self.tableView.endUpdates()
	}
	
	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		switch type {
		case .Insert:
			self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
		case .Delete:
			self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
		default:
			return
		}
	}
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		switch type {
		case .Insert:
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
			self.tableView.endUpdates() // force the endupdate here for the next line.
			self.currentlyEditedCell = self.tableView.cellForRowAtIndexPath(newIndexPath!) as? MainTableViewCell
			self.tableView.scrollToRowAtIndexPath(newIndexPath!, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
			self.updateHelperViewVisibility()
		case .Delete:
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
			self.updateHelperViewVisibility()
			self.tableView.endUpdates()
		case .Update:
			if indexPath != nil {
				let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? MainTableViewCell
				
				if cell != nil {
					self.configureCell(cell!, atIndexPath: indexPath!)
				}
			}
			self.tableView.endUpdates()
		case .Move:
			tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
			self.tableView.endUpdates()
		}
	}
}
