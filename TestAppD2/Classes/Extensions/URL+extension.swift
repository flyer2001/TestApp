//
//  URL+extension.swift
//  TestAppD2
//
//  Created by Sergei Popyvanov on 18.02.2021.
//  Copyright © 2021 Григорий Соловьев. All rights reserved.
//

import Foundation

extension URL {
    func withQueryItems(_ queryItems: [URLQueryItem]) -> URL {
        guard !queryItems.isEmpty, var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = queryItems

        return components.url ?? self
    }
}
