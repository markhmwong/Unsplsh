//
//  Photo.swift
//  Unsplsh
//
//  Created by Mark Wong on 15/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import Foundation

struct Photo: Codable {
	var id: String
	var user: PhotoUser
	var urls: PhotoUrls
	
	public init(id: String, user: PhotoUser, urls: PhotoUrls) {
		self.id = id
		self.user = user
		self.urls = urls
	}
	
	public enum CodingKeys: String, CodingKey {
		case id
		case user
		case urls
	}
}

struct PhotoUser: Codable {
	var id: String
	var username: String
	var name: String
	var bio: String? // possible for no bio
	
	public init(id: String, username: String, name: String, bio: String?) {
		self.id = id
		self.username = username
		self.name = name
		self.bio = bio
	}
	
	public enum CodingKeys: String, CodingKey {
		case id
		case username
		case name
		case bio
	}
}

struct PhotoUrls: Codable {
	var raw: String
	var full: String
	var regular: String
	var small: String
	var thumb: String
	
	public init(raw: String, full: String, regular: String, small: String, thumb: String) {
		self.raw = raw
		self.full = full
		self.regular = regular
		self.small = small
		self.thumb = thumb
	}
	
	public enum CodingKeys: String, CodingKey {
		case raw
		case full
		case regular
		case small
		case thumb
	}
}
