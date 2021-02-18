//
//  ContainerViewController.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

/// Контейнер главного экрана
final class ContainerViewController: UIViewController {
    
    // MARK: - IBOutlet

    @IBOutlet private var tableContainerView: UIView!
    @IBOutlet private var mainContainerView: UIView!
    @IBOutlet private var leadingTabelViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private var trailingTableViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private var containerNavigationItem: UINavigationItem!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        navigationItem.title = "objective-c"
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestedTagNotification(_:)), name: NSNotification.Name("RequestedTagNotification"), object: nil)
    }

    // MARK: - IBAction
    
    @IBAction private func menu(_ sender: Any) {
        if leadingTabelViewLayoutConstraint.constant == 0 {
            leadingTabelViewLayoutConstraint.constant = UIScreen.main.bounds.size.width / 2
            trailingTableViewLayoutConstraint.constant = UIScreen.main.bounds.size.width * -0.5
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            leadingTabelViewLayoutConstraint.constant = 0
            trailingTableViewLayoutConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func requestedTagNotification(_ notification: NSNotification) {
        let requestedTag = notification.object as! String
        title = requestedTag
    }
}
