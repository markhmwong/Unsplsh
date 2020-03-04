//
//  PendingOperations.swift
//  Unsplsh
//
//  Created by Mark Wong on 4/3/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import Foundation

class PendingOperations {
	lazy var downloadsInProgress: [IndexPath: Operation] = [:]
	lazy var downloadQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.name = "Download queue"
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
}

class PendingPageOperations {
	lazy var downloadsInProgress: [IndexPath: Operation] = [:]
	lazy var downloadQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.name = "Download queue"
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
}
