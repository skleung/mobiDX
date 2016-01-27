//
//  ImagesViewController.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/8/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit

class ImagesViewController: UICollectionViewController {
	var images:[ImageTag] = []

	override func viewDidLoad() {
		collectionView!.reloadData()
		collectionView!.backgroundColor = UIColor.whiteColor()
	}

	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}

	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCell

		let imageTag = images[indexPath.row]
		cell.tagImage.image = UIImage(data: imageTag.image!)
		if imageTag.treating == false {
			cell.tagImage.alpha = 0.5
		}
		let aspectRatio = CGFloat(16/9)
		let w = collectionView.bounds.size.width
		let h = CGFloat(w)*aspectRatio
		let f = cell.tagImage.frame
		cell.tagImage.frame = CGRect(x: f.minX, y: f.minY, width: w, height: h)
		return cell
	}
}
