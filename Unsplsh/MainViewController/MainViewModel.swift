//
//  MainViewModel.swift
//  Unsplsh
//
//  Created by Mark Wong on 16/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import UIKit

class MainViewModel {
	
	private let cellId = "UnsplshCellId"
	
	var photos: [PhotoRecord]? = []
	
	let pendingOperations = PendingOperations()
	
	init() {
		
	}
	
	func registerCellsFor(_ tableView: UITableView) {
		tableView.register(ImageCell.self, forCellReuseIdentifier: cellId)
	}
	
	func tableForCell(_ tableView: UITableView, indexPath: IndexPath) -> ImageCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageCell
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
		
		// because photoOperations closure runs when photoDetails is set, we need this ahead of cell.photoOperations
		cell.photoDetails = photos?[indexPath.row]
		cell.updateImage(cell.photoDetails?.image ?? UIImage(named: "Logo.png")!)
		cell.updateNameLabel(cell.photoDetails?.author ?? "Unknown")
		cell.updateBioLabel(cell.photoDetails?.bio ?? "Unknown")
		return cell
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
				tableView.reloadRows(at: [indexPath], with: .fade)
			}
		}
		
		pendingOperations.downloadsInProgress[indexPath] = downloader
		pendingOperations.downloadQueue.addOperation(downloader)
	}
	
	func heightForCell(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat {
		guard let currentImage = photos?[indexPath.row].image else {
			let height = UITableView.automaticDimension
			return height > 100.0 ? UITableView.automaticDimension : 350.0
		}
		let widthRatio = CGFloat(currentImage.size.width / currentImage.size.height)
		return widthRatio
	}
}
