//
//  CloudManager.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/22/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

private let _CloudManagerSharedInstance = CloudManager()
private let maxInAdvance: Int = 7

private let HallRecordType = "DiningDay", QuickRecordType = "QuickMenu"
let HallEntityType = "DiningDay", QuickEntityType = "QuickMenu", FoodEntityType = "Food"
private let CKDateField = "Day", CKDataField = "Data", CDDateField = "day"

private let CKQuickRecordID = "quick"

private let mostRecentDownloadKey: String = "mostRecentDiningDownload"
private let quickKey: String = "quickDownloadDate"

class CloudManager: NSObject {
	private var container: CKContainer, publicDB: CKDatabase
	
	lazy var managedObjectContext: NSManagedObjectContext? = { return (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext ?? nil }()
	
	class var sharedInstance: CloudManager { get { return _CloudManagerSharedInstance } }
	
	private var upcomingDining: Array<DiningDay>? {
		get {
			var request = NSFetchRequest(entityName: HallEntityType)
			request.predicate = NSPredicate(format: "day >= %@", comparisonDate())
			request.sortDescriptors = [NSSortDescriptor(key: CDDateField, ascending: true)]
			return managedObjectContext?.executeFetchRequest(request, error: nil) as? Array<DiningDay>
		}
	}
	
	private var firstGap: Int {
		get {
			if let upcoming = upcomingDining, lastDay = upcoming.last {
				return daysInFuture(lastDay.day) + 1
			}
			return 0
		}
	}
	
	private var quickDownloadDate: NSDate? {
		get {
			return getDownloadDate(quickKey)
		}
	}
	
	var quickData: NSData {
		get {
			var fetchRequest = NSFetchRequest(entityName: QuickEntityType)
			if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [QuickMenu] {
				for result in fetchResults {
					return result.data
				}
			}
			
			return NSData()
		}
	}
	
	override init() {
		container = CKContainer(identifier: "iCloud.BruinLife.MatthewDeCoste")
		publicDB = container.publicCloudDatabase
	}
	
	// MARK:- Favorites
	
	/// Favorites, split by whether it triggers notifications (first) or not (second)
	var favoritedFoods: Array<Array<Food>> {
		get {
			var favNotif: Array<Array<Food>> = [[], []]
			for result in favorites {
				favNotif[result.notify ? 0 : 1].append(result)
			}
			return favNotif
		}
	}
	
	private var favorites: Array<Food> {
		var fetchRequest = NSFetchRequest(entityName: FoodEntityType)
		fetchRequest.predicate = NSPredicate(format: "favorite == %@", NSNumber(bool: true))
		return managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? Array<Food> ?? []
	}
	
	func changeFavorite(food: FoodInfo, favorite: Bool) {
		defaultFoodEntity(food).favorite = favorite
		save()
	}
	
	// MARK:- Notifications
	
	// TODO: Remove all future notifications for this food
	func removeFavorite(recipe: String) {
		removeNotifications(recipe)
		
		for result in favorites {
			if result.info.recipe == recipe {
				result.favorite = false
			}
		}
		save()
	}
	
	// TODO: Add future notifications for this food
	func changeFoodNotification(recipe: String, shouldNotify notify: Bool) {
		for result in favorites {
			if result.info.recipe == recipe {
				result.notify = notify
				if notify {
					addNotifications(recipe)
				} else {
					removeNotifications(recipe)
				}
			}
		}
		save()
	}
	
	private func notificationText(place: RestaurantBrief, isHall: Bool, food: FoodInfo, meal: MealType) -> String {
		return "\(place.name(isHall)) has \(food.name) for \(meal.rawValue) (\(place.openTime.displayString) - \(place.closeTime.displayString))"
	}
	
	private func identifier(food: FoodInfo, date: NSDate, place: RestaurantBrief, isHall: Bool, meal: MealType) -> String {
		let components = currCal.components(.CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
		return "\(components.month)/\(components.day) - \(place.name(isHall)) - \(meal.rawValue) - \(food.name)"
	}
	
	private func identifier(food: FoodInfo, date: NSDate, place: Halls, isHall: Bool, meal: MealType) -> String {
		let components = currCal.components(.CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
		return "\(components.month)/\(components.day) - \(place.displayName(isHall)) - \(meal.rawValue) - \(food.name)"
	}
	
	func localNotification(food: FoodInfo, date: NSDate, place: RestaurantBrief, isHall: Bool, meal: MealType) -> UILocalNotification? {
		for notif in UIApplication.sharedApplication().scheduledLocalNotifications as! Array<UILocalNotification> {
			if let value = (notif.userInfo as! [String : String])[notificationID] where value == identifier(food, date: date, place: place, isHall: isHall, meal: meal) {
				return notif
			}
		}
		
		return nil
	}
	
	func localNotification(food: FoodInfo, date: NSDate, place: Halls, isHall: Bool, meal: MealType) -> UILocalNotification? {
		for notif in UIApplication.sharedApplication().scheduledLocalNotifications as! Array<UILocalNotification> {
			if let value = (notif.userInfo as! [String : String])[notificationID] where value == identifier(food, date: date, place: place, isHall: isHall, meal: meal) {
				return notif
			}
		}
		
		return nil
	}
	
	func removeNotification(food: FoodInfo, date: NSDate, place: RestaurantBrief, isHall: Bool, meal: MealType) {
		while let notification = localNotification(food, date: date, place: place, isHall: isHall, meal: meal) {
			UIApplication.sharedApplication().cancelLocalNotification(notification)
		}
	}
	
	func removeNotifications(recipe: String) {
		if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications as? Array<UILocalNotification> {
			for notification in notifications {
				if let userInfo = notification.userInfo as? Dictionary<String, String>, notifRecipe = userInfo[notificationRecipeID] where recipe == notifRecipe {
					UIApplication.sharedApplication().cancelLocalNotification(notification)
				}
			}
		}
	}
	
	/// Given a new favorite food to notify about, add reminders for loaded days
	func addNotifications(recipe: String) {
		// grab all loaded information
		var upcoming = map(upcomingDining ?? [], { (day: DiningDay) -> DayBrief in
			return DayBrief(dict: deserialized(day.data))
		})
		
		// process them and find out what we need to add a notification for
		for brief in upcoming {
			if let entry = brief.foods[recipe] {
				addNotification(brief, entry: entry)
			}
		}
	}
	
	/// Given a new day, add notifications for all foods we're reminding about
	func addRecurringNotifications(day: DayBrief) {
		if let notifyFoods = favoritedFoods.first where notifyFoods.count > 0 {
			var notifyRecipes = map(notifyFoods, { (food: Food) -> String in
				return food.info.recipe
			})
			
			for recipe in notifyRecipes {
				if let entry = day.foods[recipe] {
					addNotification(day, entry: entry)
				}
			}
		}
	}
	
	/// Handles a menu update removing a food we have a reminder for
	func handleDayUpdate(data: NSData) {
		if let dict = deserializedOpt(data) {
			let brief = DayBrief(dict: dict)
			removeInvalidReminders(brief)
			addMissingRecurringReminders(brief)
		}
	}
	
	func removeInvalidReminders(brief: DayBrief) {
		if let scheduled = UIApplication.sharedApplication().scheduledLocalNotifications as? Array<UILocalNotification> {
			/// All scheduled notifications for a given day
			var relevant = filter(scheduled, { (notification) -> Bool in
				if let fire = notification.fireDate {
					return currCal.isDate(brief.date, inSameDayAsDate: fire)
				}
				return false
			})
			
			for notif in relevant {
				// some old notifications don't specify the recipe. Let them go.
				if let userInfo = notif.userInfo, recipe = userInfo[notificationRecipeID] as? String {
					if let collection = brief.foods[recipe] {
						// TODO: do more to make sure the food is still where we say it is!
						continue
					} else {
						UIApplication.sharedApplication().cancelLocalNotification(notif)
					}
				}
			}
		}
	}
	
	func addMissingRecurringReminders(brief: DayBrief) {
		if let scheduled = UIApplication.sharedApplication().scheduledLocalNotifications as? Array<UILocalNotification>, remindFoods = favoritedFoods.first {
			/// All scheduled notifications for a given day
			var relevant = filter(scheduled, { (notification) -> Bool in
				if let fire = notification.fireDate {
					return currCal.isDate(brief.date, inSameDayAsDate: fire)
				}
				return false
			})
			
			var remindRecipes = map(remindFoods, { (food) -> String in
				return food.info.recipe
			})
			
			for remindRecipe in remindRecipes {
				if let collection = brief.foods[remindRecipe] {
					var contained = false
					for notif in relevant {
						if let userInfo = notif.userInfo, recipe = userInfo[notificationRecipeID] as? String where recipe == remindRecipe {
							contained = true
						}
					}
					
					if !contained {
						addNotification(brief, entry: collection) // add it!
					}
				}
			}
		}
	}
	
	/// Handles adding reminder for day and foods
	func addNotification(brief: DayBrief, entry: FoodCollection, fireHour: Int? = nil, fireMin: Int? = nil) {
		for (mealName, hallsDict) in entry.places {
			for (placeName, exists) in hallsDict {
				if let meal = MealType(rawValue: mealName), place = Halls(rawValue: placeName), placeBrief = brief.meals[meal]?.halls[place] where exists {
					addNotification(brief.date, mealType: meal, placeBrief: placeBrief, info: entry.info, fireHour: fireHour, fireMin: fireMin)
				}
			}
		}
	}
	
	/// Handles adding reminder for known food and known time
	func addNotification(date: NSDate, mealType: MealType, placeBrief: RestaurantBrief, info: FoodInfo, fireHour: Int? = nil, fireMin: Int? = nil) {
		var hour = fireHour ?? placeBrief.openTime.hour, minute = fireMin ?? placeBrief.openTime.minute
		if let fireDate = currCal.dateBySettingHour(hour, minute: minute, second: 0, ofDate: date, options: .allZeros), weekday = currCal.weekdaySymbols[currCal.component(.CalendarUnitWeekday, fromDate: fireDate) - 1] as? String {
			if localNotification(info, date: fireDate, place: placeBrief.hall, isHall: true, meal: mealType) == nil {
				// build it up
				var notif = UILocalNotification()
				notif.timeZone = .defaultTimeZone()
				notif.fireDate = fireDate
				notif.alertBody = notificationText(placeBrief, isHall: true, food: info, meal: mealType)
				
				var information = [String:String]()
				var identi = identifier(info, date: fireDate, place: placeBrief.hall, isHall: true, meal: mealType)
				println(identi)
				information[notificationID] = identi
				information[notificationFoodID] = info.name
				information[notificationRecipeID] = info.recipe
				information[notificationPlaceID] = placeBrief.name(true)
				information[notificationDateID] = weekday
				information[notificationMealID] = mealType.rawValue
				information[notificationHoursID] = "\(placeBrief.openTime.displayString) until \(placeBrief.closeTime.displayString)"
				information[notificationTimeID] = Time(hour: hour, minute: minute).displayString
				notif.userInfo = information
				
				// Sanity check: only add notifications for the future
				if notif.fireDate!.timeIntervalSinceNow > 0 {
					UIApplication.sharedApplication().scheduleLocalNotification(notif)
				}
			}
		}
	}
	
	// MARK:- Servings
	
	var eatenFoods: Array<Food> {
		get {
			var fetchRequest = NSFetchRequest(entityName: FoodEntityType)
			fetchRequest.predicate = NSPredicate(format: "servings > 0")
			
			var result: Array<Food> = []
			
			for food in managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? Array<Food> ?? [] {
				food.checkDate()
				if food.servings > 0 {
					result.append(food)
				}
			}
			
			return result
		}
	}
	
	func eatenFood(recipe: String) -> Food? {
		var request = NSFetchRequest(entityName: FoodEntityType)
		for result in managedObjectContext!.executeFetchRequest(request, error: nil) as? Array<Food> ?? [] {
			if result.info.recipe == recipe {
				result.checkDate()
				return result
			}
		}
		return nil
	}
	
	func removeEaten(info: FoodInfo) {
		changeEaten(info, servings: 0)
	}
	
	/// Either modifies or adds
	func changeEaten(food: FoodInfo, servings: Int) {
		defaultFoodEntity(food).servings = Int16(servings)
		save()
	}
	
	func foodDetails(recipe: String) -> (number: Int, favorite: Bool) {
		if let food = eatenFood(recipe) {
			return (number: Int(food.servings), favorite: food.favorite)
		}
		return (0, false)
	}
	
	// MARK:- Update dates
	
	private func updateDownloadDate(dateKey: String, modDate: NSDate) {
		NSUserDefaults.standardUserDefaults().setObject(modDate, forKey: dateKey)
		
		let mostRecent = getDownloadDate(mostRecentDownloadKey)
		if modDate.timeIntervalSinceDate(mostRecent) > 0 {
			NSUserDefaults.standardUserDefaults().setObject(modDate, forKey: mostRecentDownloadKey)
		}
		
		NSUserDefaults.standardUserDefaults().synchronize() // needed?
	}
	
	private func getDownloadDate(dateKey: String) -> NSDate {
		return NSUserDefaults.standardUserDefaults().objectForKey(dateKey) as? NSDate ?? NSDate(timeIntervalSince1970: 0)
	}
	
	// MARK:- CloudKit
	
	func downloadNewRecords(type: String = HallRecordType, completion: (error: NSError!) -> Void) {
		let gap = firstGap
		
		downloadUpdatedRecords(endDaysInAdvance: gap, completion: completion)
		downloadRecords(type, startDaysInAdvance: gap, completion: completion)
	}
	
	private func downloadUpdatedRecords(type: String = HallRecordType, endDaysInAdvance: Int = maxInAdvance, completion: (error: NSError!) -> Void) {
		if endDaysInAdvance == 0 {
			return
		}
		
		let operation = CKQueryOperation(query: CKQuery(recordType: HallRecordType, predicate: NSPredicate(format: "\(CKDateField) <= %@ AND \(CKDateField) >= %@", argumentArray: [comparisonDate(endDaysInAdvance), comparisonDate()])))
		operation.recordFetchedBlock = { (record: CKRecord!) -> Void in self.updateDiningDay(record) }
		
		publicDB.addOperation(operation)
	}
	
	private func downloadRecords(type: String, startDaysInAdvance: Int = 0, completion: (error: NSError!) -> Void) {
		if startDaysInAdvance >= maxInAdvance {
			return
		}
		
		let operation = CKQueryOperation(query: CKQuery(recordType: HallRecordType, predicate: NSPredicate(format: "\(CKDateField) <= %@ AND \(CKDateField) >= %@", argumentArray: [comparisonDate(min(maxInAdvance, max(startDaysInAdvance + 3, 6))), comparisonDate(startDaysInAdvance)])))
		operation.recordFetchedBlock = { (record: CKRecord!) -> Void in self.newDiningDay(record) }
		operation.queryCompletionBlock = { (cursor: CKQueryCursor!, error: NSError!) -> Void in
			if let err = error {
				completion(error: err)
			} else {
				self.save()
			}
		}
		
		publicDB.addOperation(operation)
	}
	
	func downloadQuickRecord(completion: (error: NSError!) -> Void) {
		publicDB.fetchRecordWithID(CKRecordID(recordName: CKQuickRecordID), completionHandler: { (record: CKRecord!, error: NSError!) -> Void in
			if error != nil {
				completion(error: error)
			} else {
				self.updateQuick(record)
			}
		})
	}
	
	// MARK: - Core Data
	private func newDiningDay(record: CKRecord) {
		updateDownloadDate(record.recordID.recordName, modDate: record.modificationDate)
		
		if let moc = managedObjectContext {
			if let recordData = record.objectForKey(CKDataField) as? NSData where validDayData(recordData) {
				diningDayEntity(record)
			} else {
				println("STOPPED UNSAFE RECORD")
			}
		}
	}
	
	private func updateDiningDay(record: CKRecord) {
		updateDownloadDate(record.recordID.recordName, modDate: record.modificationDate)
		
		if let moc = managedObjectContext, date = record.objectForKey(CKDateField) as? NSDate, data = record.objectForKey(CKDataField) as? NSData, day = diningDay(date) where day.data != data && validDayData(data) {
			println("actually updating \(record.recordID.recordName)")
			day.data = data
			NSNotificationCenter.defaultCenter().postNotificationName("DiningDayUpdated", object: nil, userInfo:["updatedData":data])
			handleDayUpdate(day.data)
			save()
		}
	}
	
	private func diningDayEntity(record: CKRecord) {
		if let moc = managedObjectContext, date = record.objectForKey(CKDateField) as? NSDate, data = record.objectForKey("Data") as? NSData {
			let compDate = comparisonDate(date: date)
			if let day = diningDay(compDate) {
				if day.data != data {
					day.data = data
					NSNotificationCenter.defaultCenter().postNotificationName("DayInfoUpdated", object: nil, userInfo:["updatedItem":day])
					handleDayUpdate(day.data)
				}
			}
			
			var newEntity = NSEntityDescription.insertNewObjectForEntityForName(HallEntityType, inManagedObjectContext: moc) as! DiningDay
			newEntity.data = data
			newEntity.day = compDate
			addRecurringNotifications(DayBrief(dict: deserialized(data)))
			NSNotificationCenter.defaultCenter().postNotificationName("NewDayInfoAdded", object: nil, userInfo:["newItem":newEntity])
			
			save()
		}
		println("\(record.recordID.recordName) is not a valid dining day record")
	}
	
	private func defaultFoodEntity(food: FoodInfo) -> Food {
		if let eaten = eatenFood(food.recipe) {
			return eaten
		} else {
			var newFood = NSEntityDescription.insertNewObjectForEntityForName("Food", inManagedObjectContext: managedObjectContext!) as! Food
			newFood.data = serialize(food)
			newFood.favorite = false
			newFood.notify = false
			newFood.date = comparisonDate()
			newFood.servings = 0
			return newFood
		}
	}
	
	private func quickEntity(record: CKRecord) {
		if let data = record.objectForKey(CKDataField) as? NSData {
			if let quick = quickMenu {
				if quick.data != data {
					quick.data = data
					NSNotificationCenter.defaultCenter().postNotificationName("QuickInfoUpdated", object: nil, userInfo: ["quickInfo":quick])
				}
				return
			}
			
			if let moc = managedObjectContext {
				var quick = NSEntityDescription.insertNewObjectForEntityForName("QuickMenu", inManagedObjectContext: moc) as! QuickMenu
				quick.data = data
				
				NSNotificationCenter.defaultCenter().postNotificationName("QuickInfoUpdated", object: nil, userInfo:["quickInfo":quick])
			}
		}
	}
	
	func diningDay(date: NSDate) -> DiningDay? {
		var request = NSFetchRequest(entityName: HallEntityType)
		request.predicate = NSPredicate(format: "\(CDDateField) == %@", comparisonDate(date: date))
		if let moc = managedObjectContext, days = moc.executeFetchRequest(request, error: nil) as? Array<DiningDay> {
			return days.first
		}
		return nil
	}
	
	var quickMenu: QuickMenu? {
		get {
			return (managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: QuickEntityType), error: nil) as? Array<QuickMenu>)?.first
		}
	}
	
	/// Returns whether day data is safe
	private func validDayData(data: NSData) -> Bool {
		if let dict = deserializedOpt(data), _ = dict["date"] as? String, _ = dict["meals"] as? Dictionary<String, Dictionary<String, AnyObject>>, _ = dict["foods"] as? Dictionary<String, Dictionary<String, AnyObject>> {
			return true
		}
		return false
	}
	
	private func updateQuick(record: CKRecord) {
		updateDownloadDate(quickKey, modDate: record.modificationDate)
		quickEntity(record)
	}
	
	func save() {
		if let moc = managedObjectContext {
			moc.save(nil)
		}
	}
	
	private func idFromDate(date: NSDate) -> CKRecordID {
		var form = NSDateFormatter()
		form.dateStyle = .ShortStyle
		return CKRecordID(recordName: form.stringFromDate(date))
	}
}
