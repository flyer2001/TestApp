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
    func getAnswers(id: Int, completion: @escaping (Result<[AnswerItem], Error>) -> Void)
    
}

final class MainStackoverflowService: StackoverflowService {
    
    // MARK: - Private Properties
    
    private let baseUrl = ServerSettings.production.baseUrl
    private let apiKey = ServerSettings.production.apiKey
    
    private let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    private let cacheService: CacheService
    private let completionQueue: DispatchQueue = DispatchQueue.main
    
    // MARK: - Init
    
    init(cacheService: CacheService) {
        self.cacheService = cacheService
    }
    
    // MARK: - Public Methods
    
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
        
        let completionQueue = self.completionQueue
        
        if cacheService.get(url.absoluteString) == nil {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // TODO: - Сетевой запрос в отдельный поток
            let task = defaultSession.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    completion(.failure(AppError.serverError))
                    return
                }
                if let question = try? JSONDecoder().decode(Question.self, from: data), let items = question.items {
                    completionQueue.async {
                        completion(.success(items))
                    }
                } else {
                    completionQueue.async {
                        completion(.failure(AppError.parsingError))
                    }
                }
                self.cacheService.set(data: data, for: url.absoluteString)
            }
            task.resume()
        } else {
            if let cacheData = cacheService.get(url.absoluteString),
               let question = try? JSONDecoder().decode(Question.self, from: cacheData),
               let items = question.items {
                completionQueue.async {
                    completion(.success(items))
                }
            }
        }
    }
    
    func getAnswers(id: Int, completion: @escaping (Result<[AnswerItem], Error>) -> Void) {
        var url = baseUrl.appendingPathComponent("/questions")
        var queryItems: [URLQueryItem] = []
        url.appendPathComponent(String(format: "/%li", id))
        url.appendPathComponent("/answers")
        queryItems.append(URLQueryItem(name: "order", value: "desc"))
        queryItems.append(URLQueryItem(name: "sort", value: "activity"))
        queryItems.append(URLQueryItem(name: "site", value: "stackoverflow"))
        queryItems.append(URLQueryItem(name: "key", value: apiKey))
        queryItems.append(URLQueryItem(name: "filter", value: "!9YdnSMKKT"))
        url = url.withQueryItems(queryItems)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let completionQueue = self.completionQueue
        
        let task = defaultSession.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completionQueue.async {
                    completion(.failure(AppError.serverError))
                }
                return
            }
            if let answerData = try? JSONDecoder().decode(Answer.self, from: data), let answers = answerData.items {
                completionQueue.async {
                    completion(.success(answers))
                }
            } else {
                completionQueue.async {
                    completion(.failure(AppError.parsingError))
                }
            }
            self.cacheService.set(data: data, for: url.absoluteString)
        }
        task.resume()
    }
}
