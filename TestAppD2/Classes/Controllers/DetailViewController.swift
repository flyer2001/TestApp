//
//  DetailViewController.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

// Контроллер экрана ответов на вопрос
final class DetailViewController: UIViewController {

    // MARK: - Public properties
    
    private var currentQuestion: Item?
    
    // MARK: - IBOutlet
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleNavigationItem: UINavigationItem!
    
    // MARK: - Private properties
    
    private let kQuestionCellIdentifier = "CellForQuestion"
    private let kAnswerCellIdentifier = "CellForAnswer"
    private var refreshControl: UIRefreshControl!
    private var activityIndicatorView: UIActivityIndicatorView!
    private var answers: [AnswerItem] = []
    private let stackoverflowService: StackoverflowService = ServiceLayer.shared.stackoverflowService
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "AnswerTableViewCell", bundle: nil), forCellReuseIdentifier: kAnswerCellIdentifier)
        tableView.register(UINib(nibName: "QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: kQuestionCellIdentifier)
        addRefreshControlOnTabelView()
        settingDynamicHeightForCell()
        addActivityIndicator()
    }
    
    // MARK: - Public Methods
    
    func loadAnswers(for currentQuestion: Item) {
        self.currentQuestion = currentQuestion
        guard let id = currentQuestion.question_id else { return }
        stackoverflowService.getAnswers(id: id) { [weak self] result in
            switch result {
            case .failure:
                // TODO: обрабобать ошибку
            print("error")
            case .success(let answers):
                self?.reload(inTableView: answers)
            }
        }
    }
    
    // MARK: - Private Methods
    
    @objc func reloadData() {
        tableView.reloadData()
        if refreshControl != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            let title = "Last update: \(formatter.string(from: Date()))"
            let attrsDictionary = [NSAttributedString.Key.foregroundColor : UIColor.black]
            let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
            refreshControl?.attributedTitle = attributedTitle
            refreshControl?.endRefreshing()
        }
    }

    private func addActivityIndicator() {
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .gray
        let bounds: CGRect = UIScreen.main.bounds
        activityIndicatorView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    
    private func addRefreshControlOnTabelView() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reloadData), for: .valueChanged)
        refreshControl?.backgroundColor = UIColor.white
        if let aControl = refreshControl {
            tableView.addSubview(aControl)
        }
    }
    
    private func settingDynamicHeightForCell() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    private func reload(inTableView answers: [AnswerItem]) {
        self.answers = answers
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.activityIndicatorView.stopAnimating()
        })
    }
}

// MARK: - UITableViewDataSource

extension DetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if answers.count == 0 {
            activityIndicatorView.startAnimating()
        }
        return answers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kQuestionCellIdentifier, for: indexPath) as? QuestionTableViewCell
            cell?.fill(currentQuestion)
            titleNavigationItem.title = "\(currentQuestion?.title ?? "")"
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kAnswerCellIdentifier, for: indexPath) as? AnswerTableViewCell
            var answer: AnswerItem?
            answer = answers[indexPath.row - 1]
            cell?.fill(answer)
            return cell!
        }
    }
}
