//
//  PhotoRecord.swift
//  Unsplsh
//
//  Created by Mark Wong on 16/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import UIKit

enum ImageStatus {
	case Failed
	case New
	case Downloaded
}

class PhotoRecord: Hashable, Identifiable {

	let id = UUID()
	let author: String
	let url: URL
	var image = UIImage(contentsOfFile: "Logo.png")
	var state = ImageStatus.New
	var bio: String?
	
	init(name: String, url: URL, bio: String?) {
		self.author = name
		self.url = url
		self.bio = bio
		
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(author)
	}
	
	static func == (lhs: PhotoRecord, rhs: PhotoRecord) -> Bool {
		return lhs.id == rhs.id
	}
}


