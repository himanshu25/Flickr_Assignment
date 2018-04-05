//
//  FlickrSearchViewController.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import UIKit

class FlickrSearchViewController: UIViewController, UISearchBarDelegate, SearchListViewControllerDelegate, FlickrSearchPagingDelegate {
   
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var spacingForSearchBar: NSLayoutConstraint!
    @IBOutlet weak var emptyImageStackView: UIStackView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var photosArray = [FlickrPhoto]()
    weak var searchListVC: SearchListViewController?
    var list = [String]()
    var selectedText: String?
    var currentText = ""
    let notificationCenter = NotificationCenter.default
    let dataSourceAndDelegate =  FlickrSearchDataSourceAndDelegate()
    
    var cellsPerRow: Int = 2 {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    static func viewController(with list: [String]?, selectedText: String?) -> FlickrSearchViewController {
        let mainView = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = mainView.instantiateViewController(withIdentifier: "searchVC") as! FlickrSearchViewController
        if let _ = list {
            searchVC.list = list!
        }
        searchVC.selectedText = selectedText
        return searchVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideCollectionViewAndIndicator()
        addNotificationObserver()
        setupDataSourceAndDelegate()
        setCellsPerRow()
        guard let selectedText = selectedText  else { return }
        searchBar.text = selectedText
        searchBarSearchButtonClicked(searchBar)
    }
    
    func hideCollectionViewAndIndicator() {
        indicator.isHidden = true
        imageCollectionView.isHidden = true
    }
        
    func setCellsPerRow() {
        if UIDevice.current.orientation.isLandscape  {
            cellsPerRow = 3
            spacingForSearchBar.constant = 40
        }
        else {
            cellsPerRow = 2
            spacingForSearchBar.constant = 60
        }
    }
    
    func setupDataSourceAndDelegate() {
        dataSourceAndDelegate.delegate = self
        searchBar.delegate = self
        imageCollectionView.delegate = dataSourceAndDelegate
        imageCollectionView.dataSource = dataSourceAndDelegate
        imageCollectionView?.contentInsetAdjustmentBehavior = .always
    }
    
    @IBAction func historyItemTapped(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        if list.count > 0 {
            searchListVC = SearchListViewController.viewController(with: list)
            searchListVC?.delegate = self
            navigationController?.present(searchListVC!, animated: true, completion: nil)
        }
        else {
            showErrorAlert(message: "No history to show.")
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        imageCollectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
        setCellsPerRow()
    }
    
    // SearchListViewControllerDelegate
    func didSelectOptionFromHistory(text: String, list: [String]) {
        searchBar.text = text
        searchBarSearchButtonClicked(searchBar)
    }
    
    // FlickrSearchPagingDelegate
    func reloadData(pageNumber: Int) {
        getNextPage(pageNumber: pageNumber)
    }
    
    func insertPaths(path: [IndexPath]) {
        imageCollectionView.reloadData()
    }
    
    // UISearchBarDelegate
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0 {
            indicator.isHidden = true
            self.title = "Search"
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        indicator.isHidden = false
        imageCollectionView.isHidden = true
        photosArray.removeAll()
        imageCollectionView.reloadData()
        if let enteredText = searchBar.text {
            FlickrManager.sharedInstance.currentSearchedText = enteredText
            currentText = enteredText
            getNextPage(pageNumber: 1)
        }
    }
   
    // get next Page with current page number
    func getNextPage(pageNumber: Int) {
        FlickrManager.sharedInstance.getPhotosWithText(text:currentText, pageNumber: pageNumber) { [weak self](error, photos) in
            if let strongSelf = self {
                guard let count = photos?.count else {
                    strongSelf.showErrorAlert(message: "")
                    return
                }
                if error == nil && (photos?.count)! > 0 {
                    for photo in photos! {
                        strongSelf.dataSourceAndDelegate.photosArray.append(photo)
                    }
                    let finalList = strongSelf.list.filter { $0 != strongSelf.currentText}
                    strongSelf.list = finalList
                    strongSelf.list.insert(strongSelf.currentText, at: 0)
                    DispatchQueue.main.async(execute: { () -> Void in
                        strongSelf.dataSourceAndDelegate.insertMore()
                        strongSelf.indicator.isHidden = true
                        strongSelf.imageCollectionView.isHidden = false
                        strongSelf.title = strongSelf.currentText
                        strongSelf.imageCollectionView.reloadData()
                    })
                    
                } else {
                    strongSelf.photosArray = []
                    DispatchQueue.main.async(execute: { () -> Void in
                        strongSelf.indicator.isHidden = true
                        strongSelf.imageCollectionView.isHidden = false
                        strongSelf.showErrorAlert(message: error?.localizedDescription ?? "")
                    })
                }
            }
        }
    }
    
    // show error
    private func showErrorAlert(message: String) {
        indicator.isHidden = true
        imageCollectionView.isHidden = true
        let alertController = UIAlertController(title: "Search Error", message: !message.isEmpty ? message : "Tha data couldn't be read because it isn't in the correct format." , preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
