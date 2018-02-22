//
//  FlowController.swift
//  YourLoc
//
//  Created by Karsten Bruns on 07.01.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import UIKit


open class AppManager {
    
    // MARK: - Properties
    
    var registeredViewControllers: [String: UIViewController.Type]
    var registeredServices: [Any]

    
    // MARK: - Lifecycle
    
    public init() {
        self.registeredServices = []
        self.registeredViewControllers = [:]
    }

    
    // MARK: - Abstract functions

    open func setup(in window: UIWindow) throws { }
    
    
    open func show(viewController: UIViewController, from sourceViewController: UIViewController, identifier: String) { }
    
    
    open func dismiss(viewController: UIViewController, identifier: String) { }
}
