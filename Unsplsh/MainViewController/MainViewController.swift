//
//  ViewController.swift
//  Unsplsh
//
//  Created by Mark Wong on 15/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

	var apiSession: ApiSession?
	
	private lazy var tableView: UITableView = {
		let view = UITableView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.dataSource = self
		view.estimatedRowHeight = 350.0
		view.rowHeight = UITableView.automaticDimension
		view.separatorStyle = .none
		view.backgroundColor = .black
		view.prefetchDataSource = self
		view.showsVerticalScrollIndicator = false
		return view
	}()
	
	private var viewModel: MainViewModel?
	
	init(viewModel: MainViewModel, session: ApiSession) {
		self.viewModel = viewModel
		self.apiSession = session
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let _vm = viewModel else { return }
		// register cells
		view.addSubview(tableView)
		_vm.registerCellsFor(tableView)
		tableView.anchorView(top: view.topAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
		
		
		apiSession?.beginRequestForLatestImages { (photos) in
			_vm.convertAndAppendPhotosToDatasource(newPhotos: photos)
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	


	deinit {
		print("Main View Controller deinit")
	}
}

extension MainViewController: UITableViewDataSourcePrefetching {
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		
//		print(indexPaths)
		guard let viewModel = viewModel else { return }
		guard let photos = viewModel.photos else { return }
		//fetch more photos if user scrolls past certain index. Since we grab 10 photos per request, we'll begin gathering more photos ever 6th index we pass
		let perPage = 20
		let fetchMore = tableView.indexPathsForVisibleRows?.contains(where: { (indexPath) -> Bool in
			let check = indexPath.row % perPage
			return check == 15
		}) ?? false
		
		if fetchMore && apiSession?.state != .inProgress {
			let pageNumber = (photos.count / perPage) + 1
			apiSession?.beginRequestForLatestImagesWith(page: pageNumber, perPage:perPage) { (newPhotos) in
				viewModel.convertAndAppendPhotosToDatasource(newPhotos: newPhotos)
				viewModel.appendToTable(tableView, pageNumber: pageNumber)
				self.apiSession?.state = .complete
			}
		}
		
	}
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let _vm = viewModel else {
			tableView.setEmptyMessage("No images were found! Please check internet connection")
			return 0
		}
		return _vm.numberOfRowsFor(tableView)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let _vm = viewModel else {
			// manual creation of cell to fallback
			let cell = tableView.dequeueReusableCell(withIdentifier: "UnsplshCellId", for: indexPath) as! ImageCell
			return cell
		}
		// standard flow
		return _vm.tableForCell(tableView, indexPath: indexPath)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let _viewModel = viewModel else { return }
		_viewModel.willDisplayCellFor(tableView, cell: cell as! ImageCell, indexPath: indexPath)
	}
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let _vm = viewModel else {
			let height = UITableView.automaticDimension
			return height > 100.0 ? UITableView.automaticDimension : 350.0
		}
		let ratio = _vm.heightForCell(tableView, indexPath: indexPath)
		return tableView.frame.width / ratio
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! ImageCell
		
		if let photoRecord = cell.photoDetails {
			let photoViewModel = PhotoViewModel(photo: photoRecord)
			let vc = PhotoViewController(viewModel: photoViewModel)
			self.present(vc, animated: true) {
				//
			}
		}
		
		
	}
}
