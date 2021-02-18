//
//  ServerSettings.swift
//  TestAppD2
//
//  Created by Sergei Popyvanov on 18.02.2021.
//  Copyright © 2021 Григорий Соловьев. All rights reserved.
//

import Foundation

struct ServerSettings {

    let baseUrl: URL
    let apiKey: String

    static let production = ServerSettings(
        baseUrl: URL(string: "https://api.stackexchange.com/2.2")!,
        apiKey: "G*0DJzE8SfBrKn4tMej85Q")
}
