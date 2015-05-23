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
	
	lazy var managedObjectContext : NSManagedObjectContext? = {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		if let moc = appDelegate.managedObjectContext { return moc }
		else { return nil }
		}()
	
	class var sharedInstance: CloudManager { get { return _CloudManagerSharedInstance } }
	
	private var firstGap: Int {
		get {
			var request = NSFetchRequest(entityName: HallEntityType)
			request.predicate = NSPredicate(format: "day >= %@", comparisonDate())
			request.sortDescriptors = [NSSortDescriptor(key: CDDateField, ascending: true)] // DateField
			
			if let moc = managedObjectContext, days = moc.executeFetchRequest(request, error: nil) as? Array<DiningDay>, lastDay = days.last {
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
		if let moc = managedObjectContext {
			var theFood = Food.foodFromInfo(moc, food: food)
			theFood.favorite = favorite
			save()
		}
	}
	
	// MARK:- Notifications
	
	// TODO: Remove all future notifications for this food
	func removeFavorite(recipe: String) {
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
			}
		}
		save()
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
		if let eaten = eatenFood(food.recipe) {
			eaten.servings = Int16(servings)
			
		} else {
			var foodEntity = Food.foodFromInfo(managedObjectContext!, food: food)
			foodEntity.servings = Int16(servings)
		}
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
	
	private func diningDayEntity(record: CKRecord) {
		if let moc = managedObjectContext, date = record.objectForKey(CKDateField) as? NSDate, data = record.objectForKey("Data") as? NSData {
			let compDate = comparisonDate(date: date)
			if let day = CloudManager.sharedInstance.diningDay(compDate) {
				if day.data != data {
					day.data = data
					NSNotificationCenter.defaultCenter().postNotificationName("DayInfoUpdated", object: nil, userInfo:["updatedItem":day])
				}
			}
			
			var newEntity = NSEntityDescription.insertNewObjectForEntityForName(HallEntityType, inManagedObjectContext: moc) as! DiningDay
			newEntity.data = data
			newEntity.day = compDate
			NSNotificationCenter.defaultCenter().postNotificationName("NewDayInfoAdded", object: nil, userInfo:["newItem":newEntity])
			
			save()
		}
		println("\(record.recordID.recordName) is not a valid dining day record")
	}
	
	private func updateDiningDay(record: CKRecord) {
		updateDownloadDate(record.recordID.recordName, modDate: record.modificationDate)
		
		if let moc = managedObjectContext, date = record.objectForKey(CKDateField) as? NSDate, data = record.objectForKey(CKDataField) as? NSData, day = diningDay(date) where day.data != data && validDayData(data) {
			println("actually updating \(record.recordID.recordName)")
			day.data = data
			NSNotificationCenter.defaultCenter().postNotificationName("DiningDayUpdated", object: nil, userInfo:["updatedData":data])
			save()
		}
	}
	
	func diningDay(date: NSDate) -> DiningDay? {
		var request = NSFetchRequest(entityName: HallEntityType)
		request.predicate = NSPredicate(format: "\(CDDateField) == %@", date)
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
		if let dict = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil) as? Dictionary<String, AnyObject>, _ = dict["date"] as? String, _ = dict["meals"] as? Dictionary<String, Dictionary<String, AnyObject>>, _ = dict["foods"] as? Dictionary<String, Dictionary<String, AnyObject>> {
			return true
		}
		return false
	}
	
	private func updateQuick(record: CKRecord) {
		updateDownloadDate(quickKey, modDate: record.modificationDate)
		
		if let moc = managedObjectContext {
			QuickMenu.dataFromInfo(moc, record: record)
		}
	}
	
	/// Can either grab the food or delete something
	func fetchDiningDay(date: NSDate) -> NSData {
		var fetchRequest = NSFetchRequest(entityName: HallRecordType)
		fetchRequest.predicate = NSPredicate(format: "\(CDDateField) == %@", comparisonDate(date: date))
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [DiningDay] {
			for result in fetchResults {
				if result.data.length > 0 {
					return result.data
				}
			}
		}
		
		return NSData()
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
