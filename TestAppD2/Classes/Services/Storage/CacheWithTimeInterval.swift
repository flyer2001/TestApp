//
//  CacheWithTimeInterval.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

/// Сервис для работы с кешируемыми данными
protocol CacheService: class {
    
    /// Получить закешированный объект по ключу
    func get(_ key: String) -> Data?
    
    /// Сохранить закешированный объект по ключу
    func set(data: Data?, for key: String)
    
    /// Сбросить закешированные данные
    func resetDefaults()
}

final class CacheWithTimeInterval: CacheService {
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }

    func get(_ key: String) -> Data? {
        var arrayOfCachedData: [Data] = []
        if UserDefaults.standard.array(forKey: "cache") != nil {
            arrayOfCachedData = UserDefaults.standard.array(forKey: "cache") as! [Data]
        } else {
            arrayOfCachedData = []
        }
        var mutableArrayOfCachedData = arrayOfCachedData
        var deletedCount = 0
        for (index, data) in arrayOfCachedData.enumerated() {
            let storedData = try! PropertyListDecoder().decode(StoredData.self, from: data)
            if abs(storedData.date.timeIntervalSinceNow) < 5*60 {
                if storedData.key == key {
                    return storedData.data
                }
            } else {
                mutableArrayOfCachedData.remove(at: index - deletedCount)
                deletedCount += 1
                UserDefaults.standard.set(mutableArrayOfCachedData, forKey: "cache")
            }
        }
        return nil
    }
    
    func set(data: Data?, for key: String) {
        var arrayOfCachedData: [Data] = []
        if let cache = UserDefaults.standard.array(forKey: "cache"),
           let cachedData = cache as? [Data] {
            arrayOfCachedData = cachedData
        }

        if let data = data, get(key) == nil,
           let storedData = try? PropertyListEncoder().encode(StoredData(key: key, date: Date(), data: data)) {
            arrayOfCachedData.append(storedData)
        }
        UserDefaults.standard.set(arrayOfCachedData, forKey: "cache")
    }
}
