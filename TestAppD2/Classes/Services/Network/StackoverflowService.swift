//
//  StackoverflowService.swift
//  TestAppD2
//
//  Created by Sergei Popyvanov on 18.02.2021.
//  Copyright © 2021 Григорий Соловьев. All rights reserved.
//

import Foundation

protocol StackoverflowService: class {
    
    /// Получить список вопросов по тегу
    /// - Parameters:
    ///   - tag: строка с тегом
    ///   - numberOfPageToLoad: номер страницы для загрузки
    ///   - completion: обработчик результата запроса
    func getQuestions(tag: String, numberOfPageToLoad: Int, completion: @escaping (Result<[Item], Error>) -> Void)
    
    /// Получить спиок ответов для вопроса
    /// - Parameters:
    ///   - id: идентификационный номер вопроса
    ///   - completion: обработчик результата запроса
    func getAnswers(id: String, completion: @escaping (Result<[Answer], Error>) -> Void)
    
}

final class MainStackoverflowService: StackoverflowService {
    
    private let baseUrl = ServerSettings.production.baseUrl
    private let apiKey = ServerSettings.production.apiKey
    
    private let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    func getQuestions(
        tag: String,
        numberOfPageToLoad: Int,
        completion: @escaping (Result<[Item], Error>) -> Void) {
        var url = baseUrl.appendingPathComponent("/questions")
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "order", value: "desc"))
        queryItems.append(URLQueryItem(name: "sort", value: "activity"))
        queryItems.append(URLQueryItem(name: "site", value: "stackoverflow"))
        queryItems.append(URLQueryItem(name: "key", value: apiKey))
        queryItems.append(URLQueryItem(name: "pageSize", value: "50"))
        queryItems.append(URLQueryItem(name: "tagged", value: "\(tag)"))
        queryItems.append(URLQueryItem(name: "page", value: "\(numberOfPageToLoad)"))
        url = url.withQueryItems(queryItems)
        
        if CacheWithTimeInterval.objectForKey(url.absoluteString) == nil {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
        
            let task = defaultSession.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    completion(.failure(AppError.serverError))
                    return
                }
                if let question = try? JSONDecoder().decode(Question.self, from: data), let items = question.items {
                    completion(.success(items))
                } else {
                    completion(.failure(AppError.parsingError))
                }
                // TODO: - Кешировать готовые модели
                CacheWithTimeInterval.set(data: data, for: url.absoluteString)
            }
            task.resume()
        } else {
            // TODO: Достать из кеша значения
            //completionHandler(CacheWithTimeInterval.objectForKey(stringURL))
        }
    }
    
    func getAnswers(id: String, completion: @escaping (Result<[Answer], Error>) -> Void) {
        // TODO: - реализовать логику для метода
    }
}

