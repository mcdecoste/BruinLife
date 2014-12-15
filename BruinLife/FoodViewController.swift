//
//  FoodViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/9/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit



enum NutritionElement: String {
//	case Servings = "Servings"
	// ounces
	case ServingSize = "Serving Size"
	
	// cal, percent
	case Calories = "Calories"
	case CaloriesFromFat = "From Fat"
	
	// grams, percent
	case TotalFat = "Total Fat"
		case SaturatedFat = "Saturated Fat"
		case TransFat = "Trans Fat"
	
	// milligrams, percent
	case Cholesterol = "Cholesterol"
	case Sodium = "Sodium"
	
	// grams, percent
	case TotalCarbs = "Total Carbohydrate"
		case DietaryFiber = "Dietary Fiber"
		case Sugars = "Sugars"
	case Protein = "Protein"
	
	// percent
	case VitaminA = "Vitamin A"
//	case VitaminB6 = "Vitamin B6"
//	case VitaminB12 = "Vitamin B12"
	case VitaminC = "Vitamin C"
	
	// percent
	case Calcium = "Calcium"
	case Iron = "Iron"
}

struct NutriTableDisplay {
	var name: String
	var indentLevel: Int
	var measures: Array<String>
}

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
		return (food?.nutrients.count)!
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let reuse = "nutrition"
		var cell = tableView.dequeueReusableCellWithIdentifier(reuse) as NutritionTableViewCell?
		if cell == nil {
			cell = NutritionTableViewCell(style: .Default, reuseIdentifier: reuse)
		}
		
		var nl: NutritionListing = (food?.nutrients[indexPath.row])!
		
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
