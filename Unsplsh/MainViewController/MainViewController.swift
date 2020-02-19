//
//  ViewController.swift
//  Unsplsh
//
//  Created by Mark Wong on 15/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

	private lazy var tableView: UITableView = {
		let view = UITableView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.dataSource = self
		view.estimatedRowHeight = 350.0
		view.rowHeight = UITableView.automaticDimension
		view.separatorStyle = .none
		view.backgroundColor = .black
		return view
	}()
	
	private var viewModel: MainViewModel?
	
	init(viewModel: MainViewModel) {
		self.viewModel = viewModel
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
		
		let apiSession = ApiSession()
		apiSession.beginRequestForLatestImages { (photos) in
			for photo in photos {
				if let url = URL(string: photo.urls.regular) {
					_vm.photos?.append(PhotoRecord(name: photo.user.name, url: url, bio:photo.user.bio ?? "Unknown"))
				}
			}
			
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}

	deinit {
		print("Main View Controller deinit")
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
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let _vm = viewModel else {
			let height = UITableView.automaticDimension
			return height > 100.0 ? UITableView.automaticDimension : 350.0
		}
		let ratio = _vm.heightForCell(tableView, indexPath: indexPath)
		return tableView.frame.width / ratio
    }
}
