//
//  UserCell.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/7/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
	var patient: Patient?

	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var locationLabel: UILabel!
	@IBOutlet var profilePicture: UIImageView!
	@IBOutlet var ageGenderLabel: UILabel!

	func setupCell() {
		if let p = patient {
			nameLabel.text = (p.last_name ?? "") + ", " + (p.first_name ?? "")
			ageGenderLabel.text = String(p.age!) + " " + (p.gender ?? "")
			let i = Int(arc4random_uniform(98) + 1)
			let gender = patient?.gender == "M" ? "men" : "women"

			// here we retrieve a random gender-specific profile image
			let url = "http://api.randomuser.me/portraits/med/" + gender + "/" + String(i) + ".jpg"
			let request = NSURLRequest(URL: NSURL(string: url)!)
			NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, err) -> Void in
				if err == nil {
					self.profilePicture.image = UIImage(data: data!)
				}
			})
			lookupAddress()
		}
	}

	private func lookupAddress() {
		if let image = patient?.images?.anyObject() as? ImageTag {
			let geocoder = CLGeocoder()
			let loc = CLLocation(latitude: Double(image.latitude ?? 39.9167), longitude: Double(image.longitude ?? 116.3833))

			// uncomment the following line to see that the reverse location works for Beijing
//			let loc = CLLocation(latitude: 39.9167, longitude: 116.3833)
			geocoder.reverseGeocodeLocation(loc, completionHandler: { (places, err) -> Void in
				if let _places = places {
					if let p = _places.first {
						self.locationLabel.text = p.locality! + ", " + p.administrativeArea!
					} else {
						self.locationLabel.text = ""
					}
				}
			})
		}
	}
}
