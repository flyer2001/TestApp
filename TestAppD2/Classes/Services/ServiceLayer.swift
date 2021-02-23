//
//  ServiceLayer.swift
//  TestAppD2
//
//  Created by Sergei Popyvanov on 18.02.2021.
//  Copyright © 2021 Григорий Соловьев. All rights reserved.
//

import Foundation

///  Сервисный слой
final class ServiceLayer {
    
    static let shared = ServiceLayer()
    
    private(set) lazy var cacheService: CacheService = CacheWithTimeInterval()
    
    private(set) lazy var stackoverflowService: StackoverflowService = MainStackoverflowService(cacheService: cacheService)
}
