//
//  AnswerItem.swift
//  TestAppD2
//
//  Created by Sergei Popyvanov on 18.02.2021.
//  Copyright © 2021 Григорий Соловьев. All rights reserved.
//

import Foundation

/// Модель ответа
struct AnswerItem: Decodable {
    var owner: Owner?
    var score: Int?
    var last_activity_date: Int?
    var body: String?
    var is_accepted: Bool?
}
