//
//  ViewController.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import UIKit

protocol SearchListViewControllerDelegate: class {
    func didSelectOptionFromHistory(text: String, list: [String])
}

class SearchListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var contentTable: UITableView!
    var list = [String]()
    weak var delegate: SearchListViewControllerDelegate?
    
    static func viewController(with list: [String]) -> SearchListViewController {
        let mainView = UIStoryboard(name: "Main", bundle: nil)
        let searchListVC = mainView.instantiateViewController(withIdentifier: "searchListVC") as! SearchListViewController
        searchListVC.list = list
        return searchListVC
    }    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        cell.label.text = list[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // if not same search as last one
            if list[indexPath.row] != FlickrManager.sharedInstance.currentSearchedText {
               delegate?.didSelectOptionFromHistory(text: list[indexPath.row], list: self.list)
            }
            dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

