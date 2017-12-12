//
//  DashboardTableViewCell.swift
//  Album
//
//  Created by Michael Hartung on 2/20/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation

class DashboardTableViewCell : UITableViewCell {
	@IBOutlet weak var albumNameText: UILabel!
	@IBOutlet weak var authorNameText: UILabel!
	@IBOutlet weak var numberOfPhotosText: UILabel!
	@IBOutlet weak var albumImageView: UIImageView!
	var photos : Array<URL> = Array()
}
