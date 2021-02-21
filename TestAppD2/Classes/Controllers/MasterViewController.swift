//
//  ViewController.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

/// Контроллер главного экрана
final class MasterViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var leadingTabelViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private var trailingTableViewLayoutConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties
    
    private let kCellIdentifier = "CellForQuestion"
    private var activityIndicatorView: UIActivityIndicatorView!
    private var questions: [Item] = []
    private var refreshControl: UIRefreshControl?
    private var loadMoreStatus = false
    private var numberOfPageToLoad: Int = 0
    private var requestedTag = ""
    private var panRecognizer: UIPanGestureRecognizer?
    private var screenEdgePanRecognizer: UIScreenEdgePanGestureRecognizer?
    private let stackoverflowService: StackoverflowService = ServiceLayer.shared.stackoverflowService
    private let cacheService: CacheService = ServiceLayer.shared.cacheService
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        tableView.register(
            UINib(nibName: "QuestionTableViewCell", bundle: nil),
            forCellReuseIdentifier: kCellIdentifier)
        numberOfPageToLoad = 1
        addRefreshControlOnTabelView()
        settingDynamicHeightForCell()
        addActivityIndicator()
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.requestedTagNotification(_:)),
            name: NSNotification.Name("RequestedTagNotification"), object: nil)
        requestedTag = ArrayOfTags.shared[0]
        definesPresentationContext = true
        questions = [Item]()
        loadQuestions(by: requestedTag)
        
        // Очищение кеша при запуске приложения
        cacheService.resetDefaults()
    }
    
    private func loadQuestions(by tag: String, completion: (() -> Void)? = nil) {
        stackoverflowService.getQuestions(
            tag: requestedTag,
            numberOfPageToLoad: numberOfPageToLoad) { [weak self] result in
            self?.activityIndicatorView.stopAnimating()
            switch result {
            case .failure:
                // TODO: - обработать ошибку
                print("error")
            case .success(let questions):
                self?.reload(inTableView: questions, removeAllObjects: true)
                self?.numberOfPageToLoad += 1
                completion?()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath: IndexPath? = tableView.indexPathForSelectedRow
        let detailViewController = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController
        let item = questions[indexPath?.row ?? 0]
        detailViewController?.currentQuestion = item
        detailViewController?.loadAnswers()
        detailViewController?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        detailViewController?.navigationItem.leftItemsSupplementBackButton = true
    }
    
    // MARK: - IBAction
    
    @IBAction func slideMenu(_ sender: Any) {
        if leadingTabelViewLayoutConstraint.constant == 0 {
            leadingTabelViewLayoutConstraint.constant = UIScreen.main.bounds.size.width / 2
            trailingTableViewLayoutConstraint.constant = UIScreen.main.bounds.size.width * -0.5
            UIView.animate(
                withDuration: 0.3,
                delay: 0.0,
                options: .layoutSubviews,
                animations: {
                    self.view.layoutIfNeeded()
                })
            screenEdgePanRecognizer?.isEnabled = false
            panRecognizer?.isEnabled = true
            tableView.allowsSelection = false
        } else {
            leadingTabelViewLayoutConstraint.constant = 0
            trailingTableViewLayoutConstraint.constant = 0
            UIView.animate(
                withDuration: 0.3,
                delay: 0.0,
                options: .layoutSubviews,
                animations: {
                self.view.layoutIfNeeded()
            })
            screenEdgePanRecognizer?.isEnabled = true
            panRecognizer?.isEnabled = false
            tableView.allowsSelection = true
        }
    }
    
    // MARK: - Private Methods
    
    private func addRefreshControlOnTabelView() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reloadData), for: .valueChanged)
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
    }
    
    private func settingDynamicHeightForCell() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    private func addActivityIndicator() {
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .gray
        let bounds: CGRect = UIScreen.main.bounds
        activityIndicatorView.center = CGPoint(
            x: bounds.size.width / 2,
            y: bounds.size.height / 2)
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    
    @objc private func reloadData() {
        numberOfPageToLoad = 1
        
        loadQuestions(by: requestedTag)
        
        if refreshControl != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            let title = "Last update: \(formatter.string(from: Date()))"
            let attrsDictionary = [NSAttributedString.Key.foregroundColor : UIColor.white]
            let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
            refreshControl?.attributedTitle = attributedTitle
            refreshControl?.endRefreshing()
        }
    }
    
    private func reload(inTableView questions: [Item], removeAllObjects: Bool) {
        if removeAllObjects { self.questions = [] }
        self.questions += questions
        tableView.reloadData()
        activityIndicatorView.stopAnimating()
    }
    
    // MARK: - Notification
    
    @objc private func requestedTagNotification(_ notification: Notification?) {
        activityIndicatorView.startAnimating()
        guard let newTag = notification?.object as? String else { return }
        numberOfPageToLoad = 1
        loadQuestions(by: requestedTag)
    }
}

// MARK: - UITableViewDataSource

extension MasterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if questions.count == 0 {
            activityIndicatorView.startAnimating()
        }
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as? QuestionTableViewCell
        if questions.count > 0 {
            cell?.fill(questions[indexPath.row])
        }
        return cell!
    }
}

// MARK: - UITableViewDelegate

extension MasterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        if actualPosition >= contentHeight && actualPosition > 0 && loadMoreStatus == false {
            let bounds: CGRect = UIScreen.main.bounds
            activityIndicatorView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height - 50)
            activityIndicatorView.startAnimating()
            loadMoreStatus = true
            loadQuestions(by: requestedTag) {
                self.reload(inTableView: self.questions, removeAllObjects: false)
                self.loadMoreStatus = false
                self.numberOfPageToLoad += 1
                self.activityIndicatorView.center = CGPoint(
                    x: bounds.size.width / 2,
                    y: bounds.size.height / 2)
            }
        }
    }
}
