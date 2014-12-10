//
//  NutritionTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/10/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class NutritionTableViewCell: UITableViewCell {
	var detailLabel = UILabel()
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		detailLabel.removeFromSuperview()
		
//		detailLabel.text = nl.measure
		detailLabel.textAlignment = .Right
		detailLabel.font = .systemFontOfSize(12)
		detailLabel.textColor = .lightTextColor()
		//		detailLabel.textColor = .blackColor()
		detailLabel.sizeToFit()
		detailLabel.center.y = center.y
		detailLabel.frame.origin.x = self.frame.width - detailLabel.frame.width - 16.0
//
//		cell?.addSubview(detailLabel)
		
		/*
		self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
		if (self) {
			// configure control(s)
			self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
			self.descriptionLabel.textColor = [UIColor blackColor];
			self.descriptionLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
			
			[self addSubview:self.descriptionLabel];
		}
		return self;
		 */
		
		
		addSubview(detailLabel)
	}

	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
}
