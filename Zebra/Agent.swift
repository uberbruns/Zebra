//
//  AppManager+Contextualized.swift
//  Zebra
//
//  Created by Karsten Bruns on 13.01.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import UIKit


public class Agent {
    
    weak var appManager: AppManager!
    weak var viewController: UIViewController?

    init(appManager: AppManager) {
        self.appManager = appManager
    }
    
    
    // MARK: - Services -
    
    public func resolve<T>(serviceOfType serviceType: T.Type, where test: (T) -> Bool) throws -> T {
        return try appManager.resolve(serviceOfType: serviceType, where: test)
    }
    
    
    public func resolve<T>(serviceOfType service: T.Type) throws -> T {
        return try appManager.resolve(serviceOfType: service)
    }
    
    
    // MARK: - View Controller -
    
    public func performSegue(withIdentifier identifier: String, data: AssemblationData = [:]) {
        guard let viewController = viewController else { return }
        appManager.performSegue(withIdentifier: identifier, from: viewController, data: data)
    }

    
    public func dismiss() {
        guard let viewController = viewController else { return }
        appManager.dismiss(viewController: viewController)
    }
}
