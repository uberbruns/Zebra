//
//  AppManager+Types.swift
//  Zebra
//
//  Created by Karsten Bruns on 12.01.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation

public typealias AssemblationData = [String : Any]



public protocol ManagedViewController: class {
    static func assemble(with data: AssemblationData, manager: AppManager) throws -> UIViewController
}



extension AppManager {
    
    public enum Error: Swift.Error {
        case cannotResolveService
        case cannotResolveViewController(identifier: String)
    }
}

