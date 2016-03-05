//
//  ViewController.swift
//  Simplistic-OSX
//
//  Created by Arnaud Thiercelin on 3/4/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate {

	@IBOutlet var listTableView: NSTableView!
	var listTableViewDataSource = ListTableViewDataSource()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}


	//MARK: - TableViewDelegate
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cellView = tableView.makeViewWithIdentifier("itemCellView", owner: self)
		
		// setup here
		return cellView
	}
}

