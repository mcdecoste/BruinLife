//
//  EmptyTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 2/3/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {
	var centralLabel = UILabel(), detailLabel = UILabel()
	var activity = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
	
	var loadState: FoodControllerLoadState = .Loading {
		didSet {
			switch loadState {
			case .Loading:
				centralLabel.text = "Loading menu..."
				detailLabel.text = ""
				activity.startAnimating()
			case .Failed:
				centralLabel.text = "Load failed."
				detailLabel.text = "Pull down to retry."
				activity.stopAnimating()
			case .Expanding:
				centralLabel.text = "Building menu..."
				detailLabel.text = ""
				activity.startAnimating()
			case .Done:
				centralLabel.text = ""
				detailLabel.text = ""
				activity.stopAnimating()
			default:
				centralLabel.text = ""
				detailLabel.text = ""
				activity.stopAnimating()
			}
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		backgroundColor = .clearColor()
		
		centralLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		centralLabel.font = .systemFontOfSize(17)
		centralLabel.textAlignment = .Center
		centralLabel.textColor = UIColor(white: 0, alpha: 0.6)
		contentView.addSubview(centralLabel)
		
		detailLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		detailLabel.font = .systemFontOfSize(14)
		detailLabel.textAlignment = .Center
		detailLabel.textColor = UIColor(white: 0, alpha: 0.5)
		contentView.addSubview(detailLabel)
		
		activity.setTranslatesAutoresizingMaskIntoConstraints(false)
		contentView.addSubview(activity)
		
		// Auto Layout
		contentView.addConstraint(NSLayoutConstraint(item: centralLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: detailLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: activity, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
		
		addConstraint("H:|-16-[central]-16-|")
		addConstraint("V:|-(>=20)-[central]-[detail]-10-[act]-|")
	}
	
	/// Helper method for Auto Layout
	func addConstraint(format: String, option: NSLayoutFormatOptions = .allZeros) {
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: option, metrics: nil, views: ["central" : centralLabel, "act" : activity, "detail" : detailLabel]))
	}
}
