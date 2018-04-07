//
//  FlickrSearchListViewController.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import UIKit
import CoreData

protocol SearchListViewControllerDelegate: class {
    func didSelectOptionFromHistory(text: String, list: [String])
}

class FlickrSearchListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var contentTable: UITableView!
    private var list = [String]()
    weak var delegate: SearchListViewControllerDelegate?
    
    static func viewController(with list: [String]) -> FlickrSearchListViewController {
        let mainView = UIStoryboard(name: "Main", bundle: nil)
        let searchListVC = mainView.instantiateViewController(withIdentifier: "searchListVC") as! FlickrSearchListViewController
        searchListVC.list = list
        searchListVC.list.reverse()
        return searchListVC
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlickrHistoryCell", for: indexPath) as! FlickrHistoryCell
        cell.label.text = list[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if list[indexPath.row] != FlickrManager.sharedInstance.currentSearchedText {
                deleteRecord(selectedtext: list[indexPath.row])
               delegate?.didSelectOptionFromHistory(text: list[indexPath.row], list: list)
            }
            dismiss(animated: true, completion: nil)
    }
    
    
    private func deleteRecord(selectedtext: String) {
        let moc = DataManager.sharedInstance.getContext()
        let request = DataManager.sharedInstance.request()
        let result = try? moc.fetch(request)
        let resultData = result as! [FlickrSearch]
        for object in resultData {
            if object.text == selectedtext {
                 moc.delete(object)
            }
        }
        do {
            try moc.save()
        } catch let error as NSError  {
          //  catch error
            print(error.localizedDescription)
        }
    }
    
    @IBAction func deleteHistoryTapped() {
        let moc = DataManager.sharedInstance.getContext()
        let request = DataManager.sharedInstance.request()
        let result = try? moc.fetch(request)
        let resultData = result as! [FlickrSearch]
        for object in resultData {
            moc.delete(object)
            list.removeAll()
            contentTable.reloadData()
        }
        do {
            try moc.save()
        } catch let error as NSError  {
            // catch error
            print(error.localizedDescription)
        }
    }
    
    @IBAction func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

