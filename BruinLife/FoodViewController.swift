//
//  FoodViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/9/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

struct NutriTableDisplay {
	var name: String
	var indentLevel: Int
	var measures: Array<String>
}

enum NutrientDisplayType {
	case oneMain
	case twoMain
	case oneSub
	case twoSub
}

class FoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	let cellHeight: CGFloat = 44.0
	let rowPairs: Array<(left: Nutrient?, right: Nutrient?)> = [(.Cal, .FatCal), (.TotFat, nil), (.SatFat, .TransFat), (.Chol, .Sodium), (.TotCarb, nil), (.DietFiber, .Sugar), (.Protein, nil), (.VitA, .VitC), (.Calcium, .Iron)]
	
	var food: MainFoodInfo?
	var foodName = UILabel()
	var nutriTable: UITableView?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		view.frame.size = preferredContentSize()
		nutriTable = UITableView(frame: view.frame, style: .Plain)
		
		view.addSubview(foodName)
		view.addSubview(nutriTable!)
		nutriTable?.delegate = self
		nutriTable?.dataSource = self
		
		nutriTable?.registerClass(NutritionTableViewCell.self, forCellReuseIdentifier: "nutrition")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setFood(info: MainFoodInfo) {
		food = info
		establishLayout()
	}
	
	func establishLayout() {
		var prefSize = preferredContentSize()
		foodName.frame.size = CGSize(width: prefSize.width * 0.9, height: prefSize.height * 0.5)
		foodName.text = food?.name
		foodName.font = .systemFontOfSize(18)
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
		return CGSize(width: 280.0, height: 360.0)
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return cellHeight
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Return the number of sections.
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Nutrient.allValues.count
//		return (food?.nutrition.count)!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let reuse = "nutrition"
		var cell = tableView.dequeueReusableCellWithIdentifier(reuse) as NutritionTableViewCell
		cell.frame.size = CGSize(width: (nutriTable?.frame.width)!, height: self.tableView(nutriTable!, heightForRowAtIndexPath: indexPath))
		
//		var nutrient = (food?.nutrition[Nutrient.allValues[indexPath.row]])!
		var nutrient = Nutrient.allValues[indexPath.row]
		var base: Int = 900
		var dv: Int? = Nutrient.allDailyValues[indexPath.row]
		if dv != nil { base = dv! }
		var randomNumber: Int = Int(rand()) % base
		var nutrientListing = NutritionListing(type: nutrient, measure: "\(randomNumber)")
		
		cell.selectionStyle = .None
		cell.setNutrition(nutrientListing)
		cell.display.center.y = cellHeight / 2
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}
