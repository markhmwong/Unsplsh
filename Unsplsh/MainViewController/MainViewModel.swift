//
//  MainViewModel.swift
//  Unsplsh
//
//  Created by Mark Wong on 16/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import UIKit

enum PhotoSection {
	case Main
}

class MainViewModel {
	
	private let cellId = "UnsplshCellId"
	
	var photos: [PhotoRecord]? = []
	
	private var imageCache = NSCache<NSString, PhotoRecord>() // <URL, Object>
	
	let pendingOperations = PendingOperations()
		
	init() {
		
	}
	
	func registerCellsFor(_ tableView: UITableView) {
		tableView.register(ImageCell.self, forCellReuseIdentifier: cellId)
	}
	
	func tableForCell(_ tableView: UITableView, indexPath: IndexPath) -> ImageCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageCell
		cell.imageView?.alpha = 0.1
		
		cell.photoOperations = { [weak self] (photo) in
			// begin to download the image if state is new
			switch photo.state {
				case .Downloaded:
					() // for infinite scroll
				case .New:
					self?.startDownload(photo, indexPath: indexPath, tableView: tableView)
				case .Failed:
					cell.imageView?.image = UIImage(named: "Logo.png")
			}
		}
		return cell
	}
	
	func willDisplayCellFor(_ tableView: UITableView, cell: ImageCell, indexPath: IndexPath) {
		if let photo = photos?[indexPath.row] {
			cell.photoDetails = photo
			DispatchQueue.main.async {
				
				cell.updateImage(cell.photoDetails?.image ?? UIImage(named: "Logo.png")!)
			}
			
			cell.updateNameLabel(cell.photoDetails?.author ?? "Unknown")
			cell.updateBioLabel(cell.photoDetails?.bio ?? "Unknown")
		}
	}
	
	func numberOfRowsFor(_ tableView: UITableView) -> Int {
		guard let p = photos else {
			return 0
		}
		return p.count
	}
	
	func startDownload(_ photo: PhotoRecord, indexPath: IndexPath, tableView: UITableView) {
		// add to queue
		guard pendingOperations.downloadsInProgress[indexPath] == nil else { return }
		
		let downloader = PhotoDownloader(photo: photo)
		
		downloader.completionBlock = {
			if downloader.isCancelled {
				return
			}
			
			// reload the cell once the download is complete to load the image
			DispatchQueue.main.async {
				self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
				tableView.beginUpdates()
				tableView.reloadRows(at: [indexPath], with: .fade)
				tableView.endUpdates()
			}
		}
		
		pendingOperations.downloadsInProgress[indexPath] = downloader
		pendingOperations.downloadQueue.addOperation(downloader)
	}
	
	func heightForCell(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat {
		guard let currentImage = photos?[indexPath.row].image else {
			let height = UITableView.automaticDimension
			return height > 100.0 ? UITableView.automaticDimension : 1.0
		}
		let widthRatio = CGFloat(currentImage.size.width / currentImage.size.height)
		return widthRatio
	}
	
	func convertAndAppendPhotosToDatasource(newPhotos: [Photo]) {
		for photo in newPhotos {
			if let url = URL(string: photo.urls.regular) {
				photos?.append(PhotoRecord(name: photo.user.name, url: url, bio:photo.user.bio ?? "Unknown"))
			}
		}
	}
	
	func appendToTable(_ tableView: UITableView, pageNumber: Int) {
		guard let photos = photos else { return }
		let startIndex = (pageNumber - 1) * 20
		let endIndex = photos.count - 1
		let arr = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }
		DispatchQueue.main.async {
			tableView.beginUpdates()
			tableView.insertRows(at: arr, with: .none)
			tableView.endUpdates()
		}
	}
}

//https://www.swiftbysundell.com/articles/caching-in-swift/ + and cache extensions
//final class Cache<Key: Hashable, Value> {
//    private let wrapped = NSCache<WrappedKey, Entry>()
//
//	func insert(_ value: Value, forKey key: Key) {
//        let entry = Entry(value: value)
//        wrapped.setObject(entry, forKey: WrappedKey(key))
//    }
//
//    func value(forKey key: Key) -> Value? {
//        let entry = wrapped.object(forKey: WrappedKey(key))
//        return entry?.value
//    }
//
//    func removeValue(forKey key: Key) {
//        wrapped.removeObject(forKey: WrappedKey(key))
//    }
//}
//
//private extension Cache {
//    final class WrappedKey: NSObject {
//        let key: Key
//
//        init(_ key: Key) { self.key = key }
//
//        override var hash: Int { return key.hashValue }
//
//        override func isEqual(_ object: Any?) -> Bool {
//            guard let value = object as? WrappedKey else {
//                return false
//            }
//
//            return value.key == key
//        }
//    }
//}
//
//private extension Cache {
//    final class Entry {
//        let value: Value
//
//		init(value: Value) {
//            self.value = value
//        }
//    }
//}
//
//extension Cache {
//    subscript(key: Key) -> Value? {
//        get { return value(forKey: key) }
//        set {
//            guard let value = newValue else {
//                // If nil was assigned using our subscript,
//                // then we remove any value for that key:
//                removeValue(forKey: key)
//                return
//            }
//
//            insert(value, forKey: key)
//        }
//    }
//}
