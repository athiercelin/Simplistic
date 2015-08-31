//
//  MainTableView.swift
//  Simplistic
//
//  Created by Arnaud Thiercelin on 8/29/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import UIKit

class MainTableView: UITableView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
//
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		NSLog("Touches: %d", touches.count)
		NSLog("All Touches: %d", (event?.allTouches()!.count)!)
		let allTouchesCount = (event?.allTouches()!.count)!
		
		if allTouchesCount == 1 {
			super.touchesBegan(touches, withEvent: event)
		} else {
			return
		}
	}
	
}
