//
//  ApiSession.swift
//  Unsplsh
//
//  Created by Mark Wong on 15/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import Foundation

enum UrlFetchInProgress {
	case inProgress
	case complete
	case idle
	case failed
}

class ApiSession {
	
	let baseUrl = "https://api.unsplash.com/photos/?client_id=" + ApiKeyService.ACCESS_KEY + "&per_page=20"
	
	var dataTask: URLSessionDataTask?
	
	var state: UrlFetchInProgress
	
	init (state: UrlFetchInProgress) {
		self.state = state
	}
	
	func beginRequestForLatestImages(completionHandler: @escaping ([Photo]) -> Void) {
				
		dataTask?.cancel()
		
		// update UI with loading indicator
		let request = URLRequest(url: URL(string: baseUrl)!)
		
		dataTask = URLSession(configuration: .default).dataTask(with: request) {
			data, response, error in
			
			if let e = error {
				// handle error
				print("Error \(e)")
			}
			
			if let _data = data {
				do {
					let decoder = JSONDecoder()
					let photos: [Photo] = try decoder.decode([Photo].self, from: _data)
					completionHandler(photos)
				} catch let error {
					print("Error \(error)")
				}
			}
		}
		dataTask?.resume()
	}
	
	func beginRequestForLatestImagesWith(page: Int, perPage: Int, completionHandler: @escaping ([Photo]) -> Void) {
		
		let pageArg = "&page=\(page)"
		
		dataTask?.cancel()
		
		// update UI with loading indicator
		let request = URLRequest(url: URL(string: baseUrl + pageArg)!)
		state = .inProgress
		dataTask = URLSession(configuration: .default).dataTask(with: request) {
			data, response, error in
			
			if let e = error {
				// handle error
				self.state = .failed
				print("Error \(e)")
			}
			
			if let _data = data {
				do {
					let decoder = JSONDecoder()
					let photos: [Photo] = try decoder.decode([Photo].self, from: _data)
//					print(photos.count)
					self.state = .complete
					completionHandler(photos)
				} catch let error {
					self.state = .failed
					print("Error \(error)")
				}
			}
		}
		dataTask?.resume()
	}
}
