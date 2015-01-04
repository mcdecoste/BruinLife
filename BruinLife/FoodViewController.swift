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
	case oneMain // bold
	case doubleMain // both bold
	case twoMain // first bold
	case oneSub // not bold (replacing twoSub)
	case empty // since no nils possible in tuples
}

class FoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	private let nutrientCellID = "nutrition"
	private let ingredientCellID = "ingredient"
	private let servingCellID = "serving"
	private let cellHeight: CGFloat = 44.0
	private let smallCellHeight: CGFloat = 36.0
	private let nutritionGap: CGFloat = 2
	private let headerGap: CGFloat = 8
	
	private let descriptionSection: Int = 0
	private let personalSection: Int = 1
		private let favoriteRow: Int = 0
		private let servingRow: Int = 1
	private let nutritionSection: Int = 2
	private let ingredientSection: Int = 3
	
	private let realWidth: CGFloat = 280
	private let realHeight: CGFloat = 460
	
	private let baseWidth: CGFloat = 280 * 0.9
	private let baseHeight: CGFloat = 460 * 0.5
	
	var food: MainFoodInfo = MainFoodInfo(name: "", type: .Regular)
	var foodLabel = UILabel()
	var typeLabel = UILabel()
	
	var nutriTable: UITableView?
	
	var ingredientsLabel = UILabel()
	var descriptionLabel = UILabel()
	var nutritionLabel = UILabel()
	var personalLabel = UILabel()
	
	// track information
	var numberOfServings = 0
	var favorited = false
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		view.frame.size = preferredContentSize()
		nutriTable = UITableView(frame: view.frame, style: .Plain)
		
		view.addSubview(foodLabel)
		view.addSubview(typeLabel)
		view.addSubview(nutriTable!)
		nutriTable?.delegate = self
		nutriTable?.dataSource = self
		nutriTable?.separatorStyle = .None
		
		nutriTable?.registerClass(NutritionTableViewCell.self, forCellReuseIdentifier: nutrientCellID)
		nutriTable?.registerClass(UITableViewCell.self, forCellReuseIdentifier: ingredientCellID)
		nutriTable?.registerClass(ServingTableViewCell.self, forCellReuseIdentifier: servingCellID)
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
		let type = food.type.rawValue
		let country = food.countryCode
		let typeText = (type != "" && country != "") ? "\(country)  •  \(type)" : (country + type)
		
		makeIngredientsLabel()
		makeDescriptionLabel()
		makeNutritionLabel()
		makePersonalLabel()
		
		foodLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		foodLabel.text = food.name
		foodLabel.font = .systemFontOfSize(18)
		foodLabel.textAlignment = .Center
		foodLabel.numberOfLines = 0 // no, not 2
		foodLabel.lineBreakMode = .ByWordWrapping
		foodLabel.sizeToFit()
		foodLabel.center.x = view.center.x
		foodLabel.frame.origin.y = realHeight * 0.015
		
		typeLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		typeLabel.text = typeText
		typeLabel.font = .systemFontOfSize(12)
		typeLabel.textAlignment = .Center
		typeLabel.sizeToFit()
		typeLabel.center.x = view.center.x
		typeLabel.frame.origin.y = foodLabel.frame.maxY
		
		
		
		var ntY = typeLabel.frame.maxY + 2
		
		nutriTable?.frame = CGRect(x: 0, y: ntY, width: realWidth, height: realHeight - ntY)
	}
	
	func preferredContentSize() -> CGSize {
		return CGSize(width: realWidth, height: realHeight) // 260 is a little too narrow
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Return the number of sections.
		var numSections = 3 // description, servings, and nutrition
		if food.ingredients != "" { numSections++ }
		return numSections
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case nutritionSection:
			return Nutrient.rowPairs.count
		case personalSection:
			return 2
		default:
			return 1
		}
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch section {
		case nutritionSection:
			return nutritionLabel.frame.maxY
		case personalSection:
			return personalLabel.frame.maxY
		default:
			return 0
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch indexPath.section {
		case nutritionSection:
			return Nutrient.rowPairs[indexPath.row].0 == .oneSub ? smallCellHeight : cellHeight
		case ingredientSection:
			return ingredientsLabel.frame.maxY + 4
		case descriptionSection:
			return descriptionLabel.frame.maxY
		default:
			return cellHeight
		}
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		var header = UIView(frame: CGRect(x: 0, y: 0, width: (nutriTable?.frame.width)!, height: self.tableView(tableView, heightForHeaderInSection: section)))
		header.backgroundColor = .whiteColor()
		
		switch section {
		case nutritionSection:
			header.addSubview(nutritionLabel)
		default:
			header.addSubview(personalLabel)
		}
		
		return header
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch indexPath.section {
		case descriptionSection, ingredientSection:
			var cell = tableView.dequeueReusableCellWithIdentifier(ingredientCellID) as UITableViewCell
			var label = indexPath.section == descriptionSection ? descriptionLabel : ingredientsLabel
			
			for subview in cell.subviews {
				if subview.isMemberOfClass(UILabel.self) { subview.removeFromSuperview() }
			}
			
			cell.textLabel?.text = nil
			
			cell.accessoryView = nil
			cell.addSubview(label)
			return cell
		case personalSection:
			switch indexPath.row {
			case favoriteRow:
				var cell = tableView.dequeueReusableCellWithIdentifier(ingredientCellID) as UITableViewCell
				
				for subview in cell.subviews {
					if subview.isMemberOfClass(UILabel.self) { subview.removeFromSuperview() }
				}
				
				cell.textLabel?.text = "Favorite Food"
				cell.textLabel?.textAlignment = .Left
				cell.textLabel?.font = .systemFontOfSize(17)
				
				var rightSwitch = UISwitch()
				rightSwitch.setOn(favorited, animated: false)
				rightSwitch.addTarget(self, action: "favoriteChanged:", forControlEvents: .ValueChanged)
				
				cell.accessoryView = rightSwitch
				return cell
			default: // case servingRow:
				var cell = tableView.dequeueReusableCellWithIdentifier(servingCellID) as ServingTableViewCell
				cell.frame.size = CGSize(width: (nutriTable?.frame.width)!, height: self.tableView(nutriTable!, heightForRowAtIndexPath: indexPath))
				
				cell.newlyDisplaying(numberOfServings, withController: self)
				
				return cell
			}
		case nutritionSection:
			var cell = tableView.dequeueReusableCellWithIdentifier(nutrientCellID) as NutritionTableViewCell
			
			var cellType: NutrientDisplayType = .empty
			var nutrientLeft: Nutrient = .Cal
			var nutrientRight: Nutrient = .FatCal
			(cellType, nutrientLeft, nutrientRight) = Nutrient.rowPairs[indexPath.row]
			
			var leftIndex = (Nutrient.allRawValues as NSArray).indexOfObject(nutrientLeft.rawValue)
			var rightIndex = (Nutrient.allRawValues as NSArray).indexOfObject(nutrientRight.rawValue)
			var nutrientListingLeft = food.nutrition[leftIndex]
			var nutrientListingRight = food.nutrition[rightIndex]
			
			cell.frame.size = CGSize(width: (nutriTable?.frame.width)!, height: self.tableView(nutriTable!, heightForRowAtIndexPath: indexPath))
			cell.backgroundColor = .clearColor()
			cell.selectionStyle = .None
			cell.setInformation((type: cellType, left: nutrientListingLeft, right: nutrientListingRight))
			
			return cell
		default:
			return tableView.dequeueReusableCellWithIdentifier(ingredientCellID) as UITableViewCell
		}
	}
	
	func makeIngredientsLabel() {
		ingredientsLabel = UILabel()
		ingredientsLabel.frame.size = CGSize(width: view.frame.width * 19/20, height: baseHeight)
		ingredientsLabel.text = "Ingredients: \(food.ingredients)"
		ingredientsLabel.font = .systemFontOfSize(11)
		ingredientsLabel.textColor = UIColor(white: 0.3, alpha: 1.0)
		ingredientsLabel.textAlignment = .Left
		ingredientsLabel.numberOfLines = 0
		ingredientsLabel.lineBreakMode = .ByWordWrapping
		ingredientsLabel.sizeToFit()
		ingredientsLabel.frame.origin.y = 8
		ingredientsLabel.center.x = view.center.x
	}
	
	func makeDescriptionLabel() {
		let hasDescription = food.description != ""
		descriptionLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		descriptionLabel.text = hasDescription ? food.description : "No description available"
		descriptionLabel.font = hasDescription ? .systemFontOfSize(12) : .italicSystemFontOfSize(12)
		descriptionLabel.textColor = hasDescription ? UIColor(white: 0.3, alpha: 1.0) : UIColor(white: 0.45, alpha: 1.0)
		descriptionLabel.textAlignment = .Center
		descriptionLabel.numberOfLines = 0
		descriptionLabel.lineBreakMode = .ByWordWrapping
		descriptionLabel.sizeToFit()
		descriptionLabel.center.x = view.center.x
	}
	
	func makeNutritionLabel() {
		nutritionLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		nutritionLabel.text = "Nutrition Facts"
		nutritionLabel.font = .boldSystemFontOfSize(20)
		nutritionLabel.textAlignment = .Left
		nutritionLabel.sizeToFit()
		nutritionLabel.frame.origin = CGPoint(x: 8, y: headerGap)
	}
	
	func makePersonalLabel() {
		personalLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		personalLabel.text = "Bruin Tracks"
		personalLabel.font = .boldSystemFontOfSize(20)
		personalLabel.textAlignment = .Left
		personalLabel.sizeToFit()
		personalLabel.frame.origin = CGPoint(x: 8, y: headerGap)
	}
	
	func servingsNumberChanged(count: Int) {
		numberOfServings = count
		// TODO: change the nutrition facts calculations based on this
	}
	
	func favoriteChanged(sender: UISwitch) {
		favorited = sender.on
		// TODO: change the color of the text here and on the other display based on it being favorited?
	}
}
