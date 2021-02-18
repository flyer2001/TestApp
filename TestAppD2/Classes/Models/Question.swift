//
//  Question.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

/// Модель списка вопросов
struct Question: Decodable {
    let items: [Item]?
}
