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

private let _CouldManagerSharedInstance = CloudManager()

class CloudManager: NSObject {
	let HallRecordType = "DiningDay"
	let DateField = "Day"
	let DataField = "Data"
	let HoursField = "Hours"
	
	private var container: CKContainer
	private var publicDB: CKDatabase
	
	lazy var managedObjectContext : NSManagedObjectContext? = {
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		if let moc = appDelegate.managedObjectContext { return moc }
		else { return nil }
		}()
	
	class var sharedInstance: CloudManager {
		return _CouldManagerSharedInstance
	}
	
	override init() {
		container = CKContainer.defaultContainer()
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
	
	func fetchNewRecords(type: String, completion: (error: NSError!) -> Void) {
		fetchRecords(type, completion: completion, startDaysInAdvance: findFirstGap())
	}
	
	func findFirstGap(daysInAdvance: Int = 13) -> Int {
		var fetchRequest = NSFetchRequest(entityName: "DiningDay")
		fetchRequest.predicate = NSPredicate(format: "day >= %@", comparisonDate())
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: false)] // DateField
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [DiningDay] {
			if fetchResults.count != 0 {
				return Int(daysInFuture(fetchResults[0].day))
			}
		}
		return 0
	}
	
	func fetchRecords(type: String, completion: (error: NSError!) -> Void, startDaysInAdvance: Int = 0) {
		if startDaysInAdvance == 13 {
			return // don't bother loading further
		}
		
		let startDate = comparisonDate(daysInFuture: startDaysInAdvance)
		let endDate = comparisonDate(daysInFuture: min(13, max(startDaysInAdvance + 3, 6)))
		
		var query = CKQuery(recordType: type, predicate: NSPredicate(format: "(\(DateField) >= %@) AND (\(DateField) <= %@)", startDate, endDate))
		query.sortDescriptors = [NSSortDescriptor(key: DateField, ascending: true)] // important?
		
		let operation = CKQueryOperation(query: query)
		var results = [CKRecord]()
		
		operation.recordFetchedBlock = { (record) -> Void in
			self.newDiningDay(record)
		}
		operation.queryCompletionBlock = { (cursor, error) in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.save()
				completion(error: error)
			})
		}
		
		publicDB.addOperation(operation)
	}
	
	// MARK: - Core Data
	func newDiningDay(record: CKRecord) {
		if let moc = managedObjectContext {
			DiningDay.dataFromInfo(moc, record: record)
		}
	}
	
	/// Can either grab the food or delete something
	func fetchDiningDay(date: NSDate) -> String {
		var fetchRequest = NSFetchRequest(entityName: "DiningDay")
		fetchRequest.predicate = NSPredicate(format: "day == %@", comparisonDate(date))
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [DiningDay] {
			for result in fetchResults {
				if countElements(result.data) > 0 {
					return result.data
				}
			}
		}
		
		return ""
	}
	
	func save() {
		var error: NSError?
		if managedObjectContext!.save(&error) {
			if error != nil { println(error?.localizedDescription) }
		}
	}
	
//	func uploadAsset(assetURL: NSURL, completion: (record: CKRecord) -> Void) {
//		var assetRecord = CKRecord(recordType: HallRecordType)
//		assetRecord.setObject(comparisonDate(NSDate()), forKey: DateField)
//		assetRecord.setObject(CKAsset(fileURL: assetURL), forKey: DataField)
//		
//		publicDB.saveRecord(assetRecord, completionHandler: { (record: CKRecord!, error: NSError!) -> Void in
//			if error != nil {
//				println("Error with uploading an asset")
//				abort()
//			} else {
//				dispatch_async(dispatch_get_main_queue(), { () -> Void in
//					completion(record: record)
//				})
//			}
//		})
//	}
	
//	func addRecord(date: NSDate, formattedString: String, completion: (record: CKRecord) -> Void) {
//		var record = CKRecord(recordType: HallRecordType)
//		record.setObject(comparisonDate(date), forKey: DateField)
//		record.setObject(formattedString.dataUsingEncoding(NSUTF8StringEncoding), forKey: DataField)
//		
//		publicDB.saveRecord(record, completionHandler: { (record: CKRecord!, error: NSError!) -> Void in
//			if error != nil {
//				println("Error with uploading an asset")
//				abort()
//			} else {
//				dispatch_async(dispatch_get_main_queue(), { () -> Void in
//					completion(record: record)
//				})
//			}
//		})
//	}
	
//	func fetchRecord(recordID: String, completion: (record: CKRecord, error: NSError) -> Void) {
//		publicDB.fetchRecordWithID(CKRecordID(recordName: recordID), completionHandler: { (record: CKRecord!, error: NSError!) -> Void in
//			if error != nil {
//				println("Error in fetching")
//				abort()
//			} else {
//				dispatch_async(dispatch_get_main_queue(), { () -> Void in
//					completion(record: record, error: error)
//				})
//			}
//		})
//	}
	
//	func saveRecord(record: CKRecord) {
//		publicDB.saveRecord(record, completionHandler: { (record: CKRecord!, error: NSError!) -> Void in
//			if error != nil {
//				println("Error while saving")
//				abort()
//			} else {
//				println("Save succeeded!")
//			}
//		})
//	}
//	
//	func deleteRecord(record: CKRecord) {
//		publicDB.deleteRecordWithID(record.recordID, completionHandler: { (recordID: CKRecordID!, error: NSError!) -> Void in
//			if error != nil {
//				println("Error while deleting")
//				abort()
//			} else {
//				println("Delete succeeded")
//			}
//		})
//	}
	
	
//	func queryForRecord(referenceName: String, completion: (records: Array<CKRecord>) -> Void) {
//		var parent = CKReference(recordID: CKRecordID(recordName: referenceName), action: .None)
//		var query =
//		
//	}
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

- (void)queryForRecordsNearLocation:(CLLocation *)location completionHandler:(void (^)(NSArray *records))completionHandler {
    
    CGFloat radiusInKilometers = 5;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"distanceToLocation:fromLocation:(location, %@) < %f", location, radiusInKilometers];
    
    CKQuery *query = [[CKQuery alloc] initWithRecordType:ItemRecordType predicate:predicate];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    
    // Just request the name field for all records since we have location range
    queryOperation.desiredKeys = @[NameField];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    [queryOperation setRecordFetchedBlock:^(CKRecord *record) {
        [results addObject:record];
    }];
    
    queryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        if (error) {
            // In your app, handle this error with such perfection that your users will never realize an error occurred.
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

*/
