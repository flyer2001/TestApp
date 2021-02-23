//
//  MenuViewController.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

/// Контроллер меню
final class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IBOutlet
    
    @IBOutlet private var menuTableView: UITableView!
    
    // MARK: - UIViewControler
    
    override func viewDidLoad() {
        menuTableView.delegate = self
        menuTableView.dataSource = self
    }
    
    // MARK: - UITableViewDelegate, UITableVIewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrayOfTags.shared.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "CellForMenuTableView",
            for: indexPath)
        cell.textLabel?.text = ArrayOfTags.shared[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(
            name: NSNotification.Name("RequestedTagNotification"),
            object: ArrayOfTags.shared[indexPath.row])
    }
}
