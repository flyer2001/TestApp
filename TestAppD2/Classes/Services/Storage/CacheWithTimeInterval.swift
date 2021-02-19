//
//  CacheWithTimeInterval.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

// TODO - Переписать в сервис
class CacheWithTimeInterval: NSObject {

    class func objectForKey(_ key: String) -> Data? {
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
    
    class func set(data: Data?, for key: String) {
        var arrayOfCachedData: [Data] = []
        if let cache = UserDefaults.standard.array(forKey: "cache"),
           let cachedData = cache as? [Data] {
            arrayOfCachedData = cachedData
        }
        if let data = data,
           CacheWithTimeInterval.objectForKey(key) == nil,
           let storedData = try? PropertyListEncoder().encode(StoredData(key: key, date: Date(), data: data)) {
            arrayOfCachedData.append(storedData)
        }
        UserDefaults.standard.set(arrayOfCachedData, forKey: "cache")
    }
}
