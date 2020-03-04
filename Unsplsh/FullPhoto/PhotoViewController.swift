//
//  PhotoViewController.swift
//  Unsplsh
//
//  Created by Mark Wong on 3/3/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import UIKit

struct PhotoViewModel {
	
	var photo: PhotoRecord
	
	init(photo: PhotoRecord) {
		self.photo = photo
	}
	
}

class PhotoViewController: UIViewController {
	
	var viewModel: PhotoViewModel?
	
	lazy var photoView: UIImageView = {
		let image = UIImage(named: "Logo.png")
		let view = UIImageView(image: image)
		view.contentMode = .scaleAspectFit
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	init(viewModel: PhotoViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .black
		// load photo full screen
		guard let viewModel = viewModel else { return }
		photoView.image = viewModel.photo.image
		view.addSubview(photoView)
		
		photoView.anchorView(top: view.topAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
	}
}
