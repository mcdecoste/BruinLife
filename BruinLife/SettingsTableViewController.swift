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
	private let tracksSection = 0
	private let feedbackSection = 1
		private let feedbackRow = 0, bugRow = 1, rateRow = 2
	
	private let cells: Array<(title: String, cells: Array<(title: String, vc: String?, acc: UITableViewCellAccessoryType)>)> =
		[
			(title: "Bruin Tracks", cells:
			[
				(title: "Upcoming Reminders", vc: "notificationVC", acc: .DisclosureIndicator),
				(title: "Favorite Foods", vc: "favoriteVC", acc: .DisclosureIndicator),
				(title: "Today's Nutrition", vc: "servingVC", acc: .DisclosureIndicator)
			]),
			
			(title: "Feedback", cells:
			[
				(title: "Email with Feedback", vc: nil, acc: .None),
				(title: "Email about a Bug", vc: nil, acc: .None),
				(title: "Rate \(displayStr) in the App Store", vc: nil, acc: .None)
			])
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
		navigationItem.title = displayStr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return cells[section].title
	}
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cells.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].cells.count
    }
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
		
		// Configure the cell...
		let info = cells[indexPath.section].cells[indexPath.row]
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
			if let vcID = cells[indexPath.section].cells[indexPath.row].vc {
				var vc = storyboard?.instantiateViewControllerWithIdentifier(vcID) as! UITableViewController
				
				switch indexPath.row {
				case 0:
					vc = vc as! NotificationTableViewController
				case 1:
					vc = vc as! FavoritesTableViewController
				case 2:
					vc = vc as! ServingsTableViewController
				default:
					vc = vc as UITableViewController
				}
				
				showViewController(vc, sender: self)
			}
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case feedbackSection:
			return versionDisplayString
		default:
			return nil
		}
	}
	
	// MARK: - MFMailComposeViewControllerDelegate
	
	func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
		controller.dismissViewControllerAnimated(true, completion: nil)
		if result.value == MFMailComposeResultSent.value {
			UIAlertView(title: "Thanks!", message: "Thank you for using Bruin Life and for your feedback!", delegate: nil, cancelButtonTitle: "Okay").show()
		}
	}
	
	private func sendGeneralEmail() {
		sendEmail("Feedback for \(displayStr) \(versionStr)", body: "Please enter your feedback here.")
	}
	
	private func sendBugEmail() {
		sendEmail("Bug in \(versionDisplayString)", body: "Please describe the bug and exactly what you did to encounter it. The more details you give, the faster I'll be able to fix them.")
	}
	
	/// Send an email with the provided subject and body
	///
	/// :param: subject The preferred subject for the email.
	/// :param: body The body of the email. The user's signature will be added on.
	private func sendEmail(subject: String, body: String) {
		if(MFMailComposeViewController.canSendMail()){
			var mailer = MFMailComposeViewController()
			mailer.mailComposeDelegate = self
			
			mailer.setSubject(subject)
			mailer.setToRecipients(["bruinlifeapp@gmail.com"])
			mailer.setMessageBody(body, isHTML: false)
			
			//Display the view controller
			presentViewController(mailer, animated: true, completion: nil)
		} else {
			UIAlertView(title: "Can't Send Email", message: "Sorry, but you can't send email from this device.", delegate: nil, cancelButtonTitle: "Darn.").show()
		}
	}
	
	/// Open the Bruin Life listing in the App Store
	private func openStore() {
		let appID = "575404770"
		let storeURL = "itms-apps://itunes.apple.com/app/id\(appID)"
		let success = UIApplication.sharedApplication().openURL(NSURL(string: storeURL)!)
		
		if !success {
			UIAlertView(title: "Can't Review", message: "Sorry, but something went wrong while trying to open the App Store.", delegate: nil, cancelButtonTitle: "Oh well").show()
		}
	}
}
