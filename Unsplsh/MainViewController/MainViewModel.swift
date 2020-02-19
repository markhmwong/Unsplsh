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
	
	private var photos: [PhotoRecord]? = []
	
	private let pendingOperations = PendingOperations()
	
	private var diffDatasource: UITableViewDiffableDataSource<PhotoSection, PhotoRecord>?
	
	init() {
		
	}
	
	func preparePhotos(data: [Photo]) {
		for photo in data {
			if let url = URL(string: photo.urls.regular) {
				photos?.append(PhotoRecord(name: photo.user.name, url: url, bio:photo.user.bio ?? "Unknown"))
			}
		}
	}
	
	func registerCellsFor(_ tableView: UITableView) {
		tableView.register(ImageCell.self, forCellReuseIdentifier: cellId)
	}
	
	func cellForTableView(_ tableView: UITableView, indexPath: IndexPath, photo: PhotoRecord) -> ImageCell {
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
		
		cell.photoDetails = photos?[indexPath.row]
		cell.updateImage(cell.photoDetails?.image ?? UIImage(named: "Logo.png")!)
		cell.updateNameLabel(cell.photoDetails?.author ?? "Unknown")
		cell.updateBioLabel(cell.photoDetails?.bio ?? "Unknown")
		return cell
	}

	func heightForCell(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat {
		guard let currentImage = photos?[indexPath.row].image else {
			let height = UITableView.automaticDimension
			return height > 100.0 ? UITableView.automaticDimension : 350.0
		}
		let widthRatio = CGFloat(currentImage.size.width / currentImage.size.height)
		return widthRatio
	}
	
	func configureDataSource(_ tableView: UITableView) {
		diffDatasource = UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, photo) -> UITableViewCell? in
			self.cellForTableView(tableView, indexPath: indexPath, photo: photo)
		}
	}
	
	func updateDatasourceSnapshot() {
		guard let _photos = photos, let _diffDatasource = diffDatasource else { return }
	
		var snapshot = NSDiffableDataSourceSnapshot<PhotoSection, PhotoRecord>()
		snapshot.appendSections([.Main])
		snapshot.appendItems(_photos)
		_diffDatasource.apply(snapshot, animatingDifferences: true)

	}
	
	func startDownload(_ photo: PhotoRecord, indexPath: IndexPath, tableView: UITableView) {
		// add to queue
		guard pendingOperations.downloadsInProgress[indexPath] == nil else { return }
		
		let downloader = PhotoDownloader(photo: photo)
		
		downloader.completionBlock = {
			if downloader.isCancelled {
				return
			}

			self.updateDatasourceSnapshot()
			self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
			
			// Important point here to mark. As the operations for downloading the image are asynchronous, the updageImage() function must be called to apply the image to the imageview
			DispatchQueue.main.async {
				if let visible = tableView.indexPathsForVisibleRows {
					if (visible.contains(indexPath)) {
						let cell = tableView.cellForRow(at: indexPath) as! ImageCell
						cell.updateImage(cell.photoDetails?.image ?? UIImage(named: "Logo.png")!)
					}
				}
			}
		}
		
		pendingOperations.downloadsInProgress[indexPath] = downloader
		pendingOperations.downloadQueue.addOperation(downloader)
	}
}
