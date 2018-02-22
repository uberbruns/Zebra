//
//  AppManager+Services.swift
//  Zebra
//
//  Created by Karsten Bruns on 12.01.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


extension AppManager {
    
    public func resolve<T>(serviceOfType serviceType: T.Type, where test: (T) -> Bool) throws -> T {
        for service in registeredServices {
            if let resolvedService = service as? T, test(resolvedService) {
                return resolvedService
            }
        }
        throw Error.cannotResolveService
    }
    
    
    public func resolve<T>(serviceOfType service: T.Type) throws -> T {
        return try resolve(serviceOfType: service) { _ in true }
    }
    
    
    public func register<T>(service: T) {
        registeredServices.append(service)
    }
}
