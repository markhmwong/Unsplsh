//
//  ImageCell.swift
//  Unsplsh
//
//  Created by Mark Wong on 16/2/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
	
	var photoDetails: PhotoRecord? {
		didSet {
			guard let _photoDetails = photoDetails else { return }
			textLabel?.text = _photoDetails.author
			
			photoOperations?(_photoDetails)
			
			if accessoryView == nil {
				let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
				accessoryView = indicator
				indicator.startAnimating()
			}
		}
	}
	
	lazy var nameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.attributedText = NSMutableAttributedString(string: "Unknown", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 10.0)!, NSAttributedString.Key.foregroundColor: UIColor.white])
		return label
	}()
	
	lazy var bioLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.attributedText = NSMutableAttributedString(string: "Unknown", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 10.0)!, NSAttributedString.Key.foregroundColor: UIColor.white])
		label.textAlignment = .right
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		return label
	}()
	
	lazy var coverLayer: CALayer = {
		let layer = CALayer()
		layer.backgroundColor = UIColor.black.cgColor
		layer.opacity = 0.1
		return layer
	}()
	
	lazy var photoView: UIImageView = {
		let image = UIImage(named: "Logo.png")
		let view = UIImageView(image: image)
		view.contentMode = .scaleAspectFit
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	var photoOperations: ((PhotoRecord) -> ())? = nil
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier)
		setupCellLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupCellLayout() {
		addSubview(photoView)
		photoView.layer.addSublayer(coverLayer)
		addSubview(nameLabel)
		addSubview(bioLabel)
		
		photoView.anchorView(top: topAnchor, bottom: bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
		nameLabel.anchorView(top: nil, bottom: bioLabel.topAnchor, leading: nil, trailing: trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
		bioLabel.anchorView(top: nil, bottom: bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
		
	}
	
	override func layoutIfNeeded() {
		super.layoutIfNeeded()
		coverLayer.frame = photoView.bounds
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
	}
	
	func updateImage(_ image: UIImage) {
		DispatchQueue.main.async {
			self.photoView.image = image
		}
	}
	
	func updateNameLabel(_ name: String) {
		DispatchQueue.main.async {
			self.nameLabel.attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 10.0)!, NSAttributedString.Key.foregroundColor: UIColor.white])
		}
	}
	
	func updateBioLabel(_ name: String) {
		DispatchQueue.main.async {
			self.bioLabel.attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 10.0)!, NSAttributedString.Key.foregroundColor: UIColor.white])
		}
	}
}
