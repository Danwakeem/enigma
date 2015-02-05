//
//  ViewController.swift
//  Enigma
//
//  Created by Bradley Slayter on 1/22/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
	let testProfileNames = [ "Sydney", "Jacob Smith", "Derek Facebook", "John iMessage", "John WhatsApp", "Sara Email" ]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// MARK: - UITableViewDataSource
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return testProfileNames.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let item = testProfileNames[indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		cell.textLabel?.text = item
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}

