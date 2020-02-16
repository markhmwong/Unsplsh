//
//  ApiSession.swift
//  Unsplsh
//
//  Created by Mark Wong on 15/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import Foundation

// request link
// download photo
// sizing?
// pending queue
// prefetching in uitableview
// Data(contentsof url)
class ApiSession {
	
	let baseUrl = "https://api.unsplash.com/photos/?client_id=" + ApiKeyService.ACCESS_KEY
	
	var dataTask: URLSessionDataTask?
	
	init () {
		
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
	
}
