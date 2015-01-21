//
//  SettingsTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit
import MessageUI // for emailing

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
	let tracksSection = 0
	let settingsSection = 1
	let feedbackSection = 2
		let feedbackRow = 0
		let bugRow = 1
		let rateRow = 2
	let aboutSection = 3
	
	let sectionTitles: Array<String?> = ["Bruin Tracks", "Settings", "Feedback", "About Bruin Life"]
	let cells: Array<Array<(title: String, vc: String?, acc: UITableViewCellAccessoryType)>> =
		[
			[
				(title: "Upcoming Reminders", vc: "notificationVC", acc: .DisclosureIndicator),
				(title: "Favorite Foods", vc:"favoriteVC", acc: .DisclosureIndicator),
				(title: "Today's Nutrition", vc: "servingVC", acc: .DisclosureIndicator)
			],
		
			[
				(title: "Favorites", vc: nil, acc: .DisclosureIndicator),
				(title: "Swipe Counter", vc: nil, acc: .DisclosureIndicator),
				(title: "Data Syncing", vc: nil, acc: .DisclosureIndicator)
			],
			
			[
				(title: "Email Feedback", vc: nil, acc: .None),
				(title: "Email About a Bug", vc: nil, acc: .None),
				(title: "Rate in App Store", vc: nil, acc: .None)
			],
		
			[
				(title: "Acknowledgements", vc: nil, acc: .DisclosureIndicator),
			]
		]
	
	override init(style: UITableViewStyle) {
		super.init(style: .Grouped)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		navigationItem.title = "Bruin Life"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sectionTitles[section]
	}
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
		
		// Configure the cell...
		let info = cells[indexPath.section][indexPath.row]
		cell.textLabel?.text = info.title
		cell.accessoryType = info.acc
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == feedbackSection {
			switch indexPath.row {
			case feedbackRow:
				sendGeneralEmail()
			case bugRow:
				sendBugEmail()
			case rateRow:
				openStore()
			default:
				println()
			}
		} else {
			if let vcID = cells[indexPath.section][indexPath.row].vc {
				var vc = storyboard?.instantiateViewControllerWithIdentifier(vcID) as UITableViewController
				
				switch indexPath.row {
				case 0:
					vc = vc as NotificationTableViewController
				case 1:
					vc = vc as FavoritesTableViewController
				case 2:
					vc = vc as ServingsTableViewController
				default:
					vc = vc as UITableViewController
				}
				
				self.showViewController(vc, sender: self)
			}
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	// MARK: - MFMailComposeViewControllerDelegate
	
	func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func sendGeneralEmail() {
		sendEmail("Bruin Life Feedback", body: "Please enter your feedback here.\n\nThanks for using Bruin Life!")
	}
	
	func sendBugEmail() {
		sendEmail("Found a Bug!", body: "Please list the bug you found and exactly how you run into it. The more details you give, the faster I'll be able to fix them.\n\nThanks for using Bruin Life!")
	}
	
	/// Send an email with the provided subject and body
	///
	/// :param: subject The preferred subject for the email.
	/// :param: body The body of the email. The user's signature will be added on.
	func sendEmail(subject: String, body: String) {
		if(MFMailComposeViewController.canSendMail()){
			var mailer = MFMailComposeViewController()
			mailer.mailComposeDelegate = self
			
			mailer.setSubject(subject)
			mailer.setToRecipients(["bruinlifeapp@gmail.com"])
			mailer.setMessageBody(body, isHTML: true)
			
			//Display the view controller
			self.presentViewController(mailer, animated: true, completion: nil)
		} else {
			UIAlertView(title: "Can't Send Email", message: "Sorry, but you can't send email from this device.", delegate: nil, cancelButtonTitle: "Darn.").show()
		}
	}
	
	/// Open the Bruin Life listing in the App Store
	func openStore() {
		let appID = "575404770"
		let storeURL = "itms-apps://itunes.apple.com/app/id\(appID)"
		UIApplication.sharedApplication().openURL(NSURL(string: storeURL)!) // var success =
	}
}
