//
//  CloudManager.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/22/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit
import Foundation
import CloudKit

import CoreData

private let _CloudManagerSharedInstance = CloudManager()
private let maxInAdvance: Int = 7

class CloudManager: NSObject {
	let HallRecordType = "DiningDay", QuickRecordType = "QuickMenu"
	let CKDateField = "Day", CKDataField = "Data"
	let CDDateField = "day"
	
	private var container: CKContainer
	private var publicDB: CKDatabase
	
	lazy var managedObjectContext : NSManagedObjectContext? = {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		if let moc = appDelegate.managedObjectContext { return moc }
		else { return nil }
		}()
	
	class var sharedInstance: CloudManager {
		get {
			return _CloudManagerSharedInstance
		}
	}
	
	override init() {
		container = CKContainer(identifier: "iCloud.BruinLife.MatthewDeCoste")
		publicDB = container.publicCloudDatabase
	}
	
	func requestDiscoverabilityPermission(completion: (discoverable: Bool) -> Void) {
		container.requestApplicationPermission(.PermissionUserDiscoverability, completionHandler: { (applicationPermissionStatus: CKApplicationPermissionStatus, error: NSError!) -> Void in
			if error != nil {
				println("error happened")
				abort()
			} else {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					completion(discoverable: applicationPermissionStatus == .Granted)
				})
			}
		})
	}
	
	func discoverUserInfo(completion: (user: CKDiscoveredUserInfo) -> Void) {
		container.fetchUserRecordIDWithCompletionHandler { (recordID: CKRecordID!, error: NSError!) -> Void in
			if error != nil {
				println("error!")
				abort()
			} else {
				self.container.discoverUserInfoWithUserRecordID(recordID, completionHandler: { (user: CKDiscoveredUserInfo!, error: NSError!) -> Void in
					if error != nil {
						println("ERROR")
						abort()
					} else {
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							completion(user: user)
						})
					}
				})
			}
		}
	}
	
	func fetchNewRecords(type: String = "DiningDay", completion: (error: NSError!) -> Void) {
		let gap = findFirstGap()
		println("The gap is \(gap)")
		
//		checkForDormUpdates(upTo: gap, completion: completion) // make sure we're okay on what exists
		fetchUpdatedRecords(endDaysInAdvance: gap, completion: completion)
		fetchRecords(type, startDaysInAdvance: gap, completion: completion)
	}
	
	func findFirstGap(daysInAdvance: Int = maxInAdvance) -> Int {
		var fetchRequest = NSFetchRequest(entityName: "DiningDay")
		fetchRequest.predicate = NSPredicate(format: "day >= %@", comparisonDate())
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: CDDateField, ascending: true)] // DateField
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [DiningDay] where fetchResults.count != 0 {
			return daysInFuture(fetchResults.first!.day) + 1
		}
		return 0
	}
	
	private func fetchUpdatedRecords(type: String = "DiningDay", endDaysInAdvance: Int = maxInAdvance, completion: (error: NSError!) -> Void) {
		if endDaysInAdvance == 0 {
			completion(error: NSError(domain: "Nothing to Update", code: 42, userInfo: nil))
			return
		}
		let pred = NSPredicate(format: "\(CKDateField) <= %@ AND \(CKDateField) >= %@", argumentArray: [comparisonDate(daysInFuture: endDaysInAdvance), comparisonDate()])
		let operation = CKQueryOperation(query: CKQuery(recordType: HallRecordType, predicate: pred))
		operation.recordFetchedBlock = { (record: CKRecord!) -> Void in
			self.updateDiningDay(record)
		}
		operation.queryCompletionBlock = { (cursor: CKQueryCursor!, error: NSError!) -> Void in
			if let err = error {
				completion(error: err)
			}
		}
		
		publicDB.addOperation(operation)
	}
	
	private func fetchRecords(type: String, startDaysInAdvance: Int = 0, completion: (error: NSError!) -> Void) {
		if startDaysInAdvance >= maxInAdvance {
			completion(error: NSError(domain: "Nothing to Load", code: 42, userInfo: nil))
			return
		}
		
		let startDate = comparisonDate(daysInFuture: startDaysInAdvance)
		let endDate = comparisonDate(daysInFuture: min(maxInAdvance, max(startDaysInAdvance + 3, 6)))
		let pred = NSPredicate(format: "\(CKDateField) <= %@ AND \(CKDateField) >= %@", argumentArray: [endDate, startDate])
		let operation = CKQueryOperation(query: CKQuery(recordType: HallRecordType, predicate: pred))
		operation.recordFetchedBlock = { (record: CKRecord!) -> Void in
			println("Fetched for \(record.recordID.recordName)")
			self.newDiningDay(record)
		}
		operation.queryCompletionBlock = { (cursor: CKQueryCursor!, error: NSError!) -> Void in
			if let err = error {
				completion(error: err)
			} else {
				self.save()
			}
		}
		
		publicDB.addOperation(operation)
	}
	
	/// Versions up to 2.1: Reloads all days, saves them.
	/// Versions 2.2+: does predicate fanciness to prevent extra loads
//	func checkForDormUpdates(upTo: Int = maxInAdvance, completion: (error: NSError!) -> Void) {
//		if upTo == 0 {
//			return
//		}
//		
//		var form = NSDateFormatter()
//		form.dateStyle = .ShortStyle
//		
//		let comp = { (record: CKRecord!, error: NSError!) -> Void in
//			if let err = error {
//				completion(error: err)
//			} else {
//				self.updateDiningDay(record)
//			}
//		}
//		
//		for advance in 0...upTo {
//			fetchRecord(form.stringFromDate(comparisonDate(daysInFuture: advance)), completion: comp)
//		}
//	}
	
	private let mostRecentDownloadKey: String = "mostRecentDiningDownload"
	private let quickKey: String = "quickDownloadDate"
	private func updateDownloadDate(dateKey: String, modDate: NSDate) {
		NSUserDefaults.standardUserDefaults().setObject(modDate, forKey: dateKey)
		
		let mostRecent = downloadDate(mostRecentDownloadKey)
		if modDate.timeIntervalSinceDate(mostRecent) > 0 {
			NSUserDefaults.standardUserDefaults().setObject(modDate, forKey: mostRecentDownloadKey)
		}
		
		NSUserDefaults.standardUserDefaults().synchronize() // needed?
	}
	
	private func downloadDate(dateKey: String) -> NSDate {
		return NSUserDefaults.standardUserDefaults().objectForKey(dateKey) as? NSDate ?? NSDate(timeIntervalSince1970: 0)
	}
	
	private func quickDownloadDate() -> NSDate? {
		return downloadDate(quickKey)
	}
	
	// MARK: - Core Data
	private func newDiningDay(record: CKRecord) {
		updateDownloadDate(record.recordID.recordName, modDate: record.modificationDate)
		
		if let moc = managedObjectContext {
			DiningDay.dataFromInfo(moc, record: record)
			moc.save(nil)
		}
	}
	
	private func updateDiningDay(record: CKRecord) {
		println("checking update for \(record.recordID.recordName)")
		updateDownloadDate(record.recordID.recordName, modDate: record.modificationDate)
		
		if let moc = managedObjectContext {
			var req = NSFetchRequest(entityName: "DiningDay")
			req.predicate = NSPredicate(format: "\(CDDateField) == %@", argumentArray: [record.valueForKey(CKDateField)!])
			var madeChanges = false
			
			if let results = moc.executeFetchRequest(req, error: nil) as? [DiningDay] {
				println("\(record.recordID.recordName) as \(results.count) results")
				
				for day in results {
					if let recordDayData = record.valueForKey(CKDataField) as? NSData {
						if day.data != recordDayData {
							println("actually updating \(record.recordID.recordName)")
						}
						day.data = recordDayData
						madeChanges = true
					}
				}
				
			}
			
			if madeChanges {
				save()
			}
		}
	}
	
	private func updateQuick(record: CKRecord) {
		updateDownloadDate(quickKey, modDate: record.modificationDate)
		
		if let moc = managedObjectContext {
			QuickMenu.dataFromInfo(moc, record: record)
		}
	}
	
	/// Can either grab the food or delete something
	func fetchDiningDay(date: NSDate) -> NSData {
		var fetchRequest = NSFetchRequest(entityName: "DiningDay")
		fetchRequest.predicate = NSPredicate(format: "\(CDDateField) == %@", comparisonDate(date))
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [DiningDay] {
			for result in fetchResults {
				if result.data.length > 0 {
					return result.data
				}
			}
		}
		
		return "".dataUsingEncoding(NSUTF8StringEncoding)!
	}
	
	func fetchQuick() -> NSData {
		var fetchRequest = NSFetchRequest(entityName: "QuickMenu")
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [QuickMenu] {
			for result in fetchResults {
				if result.data.length > 0 {
					return result.data
				}
			}
		}
		
		return "".dataUsingEncoding(NSUTF8StringEncoding)!
	}
	
	func save() {
		var error: NSError?
		if managedObjectContext!.save(&error) {
			if error != nil { println(error?.localizedDescription) }
		}
	}
	
	private func idFromDate(date: NSDate) -> CKRecordID {
		var form = NSDateFormatter()
		form.dateStyle = .ShortStyle
		return CKRecordID(recordName: form.stringFromDate(date))
	}
	
	func fetchRecord(recordID: String, completion: (record: CKRecord!, error: NSError!) -> Void) {
		println(recordID)
		publicDB.fetchRecordWithID(CKRecordID(recordName: recordID), completionHandler: { (record: CKRecord!, error: NSError!) -> Void in
			if error != nil {
				println("Error in fetching \(recordID)")
			} else {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					completion(record: record, error: error)
				})
			}
		})
	}
	
	func fetchQuickRecord() {
		publicDB.fetchRecordWithID(CKRecordID(recordName: "quick"), completionHandler: { (record: CKRecord!, error: NSError!) -> Void in
			if error != nil {
				println("quick " + error.description)
			} else {
				self.updateQuick(record)
			}
		})
	}
}

/*
- (void)fetchRecordWithID:(NSString *)recordID completionHandler:(void (^)(CKRecord *record))completionHandler;
- (void)queryForRecordsNearLocation:(CLLocation *)location completionHandler:(void (^)(NSArray *records))completionHandler;

- (void)saveRecord:(CKRecord *)record;
- (void)deleteRecord:(CKRecord *)record;
- (void)fetchRecordsWithType:(NSString *)recordType completionHandler:(void (^)(NSArray *records))completionHandler;
- (void)queryForRecordsWithReferenceNamed:(NSString *)referenceRecordName completionHandler:(void (^)(NSArray *records))completionHandler;

@property (nonatomic, readonly, getter=isSubscribed) BOOL subscribed;
- (void)subscribe;
- (void)unsubscribe;

NSString * const ItemRecordType = @"Items";
NSString * const NameField = @"name";
NSString * const LocationField = @"location";

NSString * const ReferenceSubItemsRecordType = @"ReferenceSubitems";

- (void)queryForRecordsWithReferenceNamed:(NSString *)referenceRecordName completionHandler:(void (^)(NSArray *records))completionHandler {
    
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:referenceRecordName];
    CKReference *parent = [[CKReference alloc] initWithRecordID:recordID action:CKReferenceActionNone];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@", parent];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:ReferenceSubItemsRecordType predicate:predicate];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    // Just request the name field for all records
    queryOperation.desiredKeys = @[NameField];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    queryOperation.recordFetchedBlock = ^(CKRecord *record) {
        [results addObject:record];
    };
    
    queryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        if (error) {
            // In your app, you should do the Right Thing
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
            abort();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completionHandler(results);
            });
        }
    };
    
    [self.publicDatabase addOperation:queryOperation];
}

- (void)subscribe {
    
    if (self.subscribed == NO) {
        
        NSPredicate *truePredicate = [NSPredicate predicateWithValue:YES];
        CKSubscription *itemSubscription = [[CKSubscription alloc] initWithRecordType:ItemRecordType
                                                                            predicate:truePredicate
                                                                              options:CKSubscriptionOptionsFiresOnRecordCreation];
        
        
        CKNotificationInfo *notification = [[CKNotificationInfo alloc] init];
        notification.alertBody = @"New Item Added!";
        itemSubscription.notificationInfo = notification;
        
        [self.publicDatabase saveSubscription:itemSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
            if (error) {
                // In your app, handle this error appropriately.
                NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
                abort();
            } else {
                NSLog(@"Subscribed to Item");
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:YES forKey:@"subscribed"];
                [defaults setObject:subscription.subscriptionID forKey:@"subscriptionID"];
            }
        }];
    }
}

- (void)unsubscribe {
    if (self.subscribed == YES) {
        
        NSString *subscriptionID = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptionID"];
        
        CKModifySubscriptionsOperation *modifyOperation = [[CKModifySubscriptionsOperation alloc] init];
        modifyOperation.subscriptionIDsToDelete = @[subscriptionID];
        
        modifyOperation.modifySubscriptionsCompletionBlock = ^(NSArray *savedSubscriptions, NSArray *deletedSubscriptionIDs, NSError *error) {
            if (error) {
                // In your app, handle this error beautifully.
                NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
                abort();
            } else {
                NSLog(@"Unsubscribed to Item");
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"subscriptionID"];
            }
        };
        
        [self.publicDatabase addOperation:modifyOperation];
    }
}

- (BOOL)isSubscribed {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptionID"] != nil;
}

*/
