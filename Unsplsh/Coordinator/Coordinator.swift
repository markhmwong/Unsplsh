//
//  Coordinator.swift
//  Unsplsh
//
//  Created by Mark Wong on 3/3/20.
//  Copyright © 2020 Mark Wong. All rights reserved.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
	var childCoordinators: [Coordinator] { get set }
	
	func start()
	func dismiss()
}
