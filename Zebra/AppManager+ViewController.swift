//
//  AppManager+ViewController.swift
//  Zebra
//
//  Created by Karsten Bruns on 12.01.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import UIKit


extension AppManager {
    
    public func managedViewController(_ makeViewController: (Agent) throws -> UIViewController) rethrows -> UIViewController {
        let agent = Agent(appManager: self)
        let viewController = try makeViewController(agent)
        agent.viewController = viewController
        return viewController
    }

    
    public func register<VC: ManagedViewController & UIViewController>(viewControllerClass: VC.Type, forIdentifier identifier: String) {
        registeredViewControllers[identifier] = viewControllerClass
    }

    
    public func performSegue(to identifier: String, from sourceViewController: UIViewController, data: AssemblationData = [:]) {
        if let viewController = try? viewController(forIdentifier: identifier, data: data) {
            show(viewController: viewController, from: sourceViewController, identifier: identifier)
            
        } else {
            
            let customAlertController = { () -> UIAlertController? in
                if let viewController = try? self.viewController(forIdentifier: "appManager.alert", data: ["identifier": identifier]) {
                    return viewController as? UIAlertController
                }
                return nil
            }
            
            let defaultAlertController = { () -> UIAlertController in
                let title = "Internal Error"
                let message = "Could not resolve view controller with identifier \"\(identifier)\""
                let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                return alertController
            }
            
            let alertController = customAlertController() ?? defaultAlertController()
            sourceViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    public func dismiss(viewController: UIViewController) {
        guard let entry = registeredViewControllers.first(where: { (_, vcType) -> Bool in
            return vcType == type(of: viewController)
        }) else {
            return
        }

        self.dismiss(viewController: viewController, identifier: entry.key)
    }
    
    
    public func viewController(forIdentifier identifier: String, data: AssemblationData = [:]) throws -> UIViewController {
        guard let viewControllerClass = registeredViewControllers[identifier] as? ManagedViewController.Type else {
            throw AppManager.Error.cannotResolveViewController(identifier: identifier)
        }
        
        return try viewControllerClass.assemble(with: data, manager: self)
    }
}
