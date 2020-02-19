//
//  PhotoDownloader.swift
//  Unsplsh
//
//  Created by Mark Wong on 16/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import UIKit

class PhotoDownloader: Operation {
	
	let photo: PhotoRecord
	
	init(photo: PhotoRecord) {
		self.photo = photo
	}
	
	override func main() {
		if isCancelled {
		  return
		}
		
		guard let imageData = try? Data(contentsOf: photo.url) else { return }
		
		if isCancelled {
		  return
		}
		
		if !imageData.isEmpty {
			photo.image = UIImage(data:imageData)
			photo.state = .Downloaded
		} else {
			photo.state = .Failed
			photo.image = UIImage(named: "Logo.png")
		}
	}
	
}

// Ray Wenderlich NSOperation tutorials
class PendingOperations {
	lazy var downloadsInProgress: [IndexPath: Operation] = [:]
	lazy var downloadQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.name = "Download queue"
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
}
