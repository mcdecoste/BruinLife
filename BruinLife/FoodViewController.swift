//
//  FoodViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/9/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	var food: FoodInfo?
	
	var foodName = UILabel()
//	@IBOutlet weak var nutriTable: NutritionTableView!
	var nutriTable: NutritionTableView?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		view.frame.size = preferredContentSize()
		nutriTable = NutritionTableView(frame: view.frame, style: .Plain)
		
		view.addSubview(foodName)
		view.addSubview(nutriTable!)
		nutriTable?.delegate = self
		nutriTable?.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setFood(info: FoodInfo) {
		food = info
		establishLayout()
	}
	
	func establishLayout() {
		var prefSize = preferredContentSize()
		foodName.frame.size = CGSize(width: prefSize.width * 0.9, height: prefSize.height * 0.5)
		foodName.text = food?.name
		foodName.font = .systemFontOfSize(24)
		foodName.textAlignment = .Center
		foodName.numberOfLines = 0 // no, not 2
		foodName.lineBreakMode = .ByWordWrapping
		foodName.sizeToFit()
		foodName.center.x = view.center.x
		foodName.frame.origin.y = prefSize.height * 0.03
		
		var ntYval = foodName.frame.maxY
		
		nutriTable?.frame = CGRect(x: 0, y: ntYval, width: prefSize.width, height: prefSize.height - ntYval)
	}
	
	func preferredContentSize() -> CGSize {
		return CGSize(width: 260.0, height: 360.0)
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 44.0
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Return the number of sections.
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (food?.nuts.count)!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let reuse = "nutrition"
		var cell = tableView.dequeueReusableCellWithIdentifier(reuse) as NutritionTableViewCell?
		if cell == nil {
			cell = NutritionTableViewCell(style: .Default, reuseIdentifier: reuse)
		}
		
		var nl: NutritionListing = (food?.nuts[indexPath.row])!
		
		cell?.selectionStyle = .None
		cell?.textLabel?.text = nl.name
//		cell?.detailTextLabel?.text = nl.measure
//		cell.detailTextLabel?.text = nl.measure
		
		cell?.detailLabel.text = nl.measure
		
//		var detailLabel = UILabel()
//		detailLabel.text = nl.measure
//		detailLabel.textAlignment = .Right
//		detailLabel.font = .systemFontOfSize(12)
//		detailLabel.textColor = .lightTextColor()
////		detailLabel.textColor = .blackColor()
//		detailLabel.sizeToFit()
//		detailLabel.center.y = (cell?.center.y)!
//		detailLabel.frame.origin.x = (cell?.frame.width)! - detailLabel.frame.width - 16.0
//		
//		cell?.addSubview(detailLabel)
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
