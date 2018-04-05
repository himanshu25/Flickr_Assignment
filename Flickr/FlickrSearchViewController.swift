//
//  FlickrSearchViewController.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class FlickrSearchViewController: UIViewController, UICollectionViewDelegate, UISearchBarDelegate, SearchListViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var photosArray = [FlickrPhoto]()
    weak var searchListVC: SearchListViewController?
    @IBOutlet weak var spacingForSearchBar: NSLayoutConstraint!
    @IBOutlet weak var emptyImageStackView: UIStackView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var list = [String]()
    var selectedText: String?
    var currentText = ""
    let notificationCenter = NotificationCenter.default
    var cellsPerRow: Int = 2 {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    
    var pageNumber = 1
    var min = 0
    var max = 9
    let dataSourceAndDelegate =  FlickrSearchDataSourceAndDelegate()
    
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
        indicator.isHidden = true
        imageCollectionView.isHidden = true
        addNotificationObserver()
        setupDataSourceAndDelegate()
        setCellsPerRow()
        guard let selectedText = selectedText  else { return }
        searchBar.text = selectedText
        searchBarSearchButtonClicked(searchBar)
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
        searchBar.delegate = self
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView?.contentInsetAdjustmentBehavior = .always
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
            getNextPage(pageNumber: pageNumber)
        }
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
    
    func didSelectOptionFromHistory(text: String, list: [String]) {
        searchBar.text = text
        searchBarSearchButtonClicked(searchBar)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0 {
            indicator.isHidden = true
            self.title = "Search"
        }
    }
    
    private func showErrorAlert(message: String) {
        indicator.isHidden = true
        imageCollectionView.isHidden = true
        let alertController = UIAlertController(title: "Search Error", message: !message.isEmpty ? message : "Tha data couldn't be read because it isn't in the correct format." , preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrSearchCell", for: indexPath) as! SearchCell
        cell.setupWithPhoto(flickr: photosArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == photosArray.count - 1 {
            moreData()
        }
    }
    
    func moreData() {
       pageNumber += 1
        getNextPage(pageNumber: pageNumber)
    }
    
    
    func insertMore() {
        var paths = [IndexPath]()
        for _ in 0..<10 {
            paths.append(IndexPath(row: photosArray.count - 1, section: 0))
        }
        imageCollectionView.insertItems(at: paths)
    }
    
    func getNextPage(pageNumber: Int) {
        FlickrManager.sharedInstance.getPhotosWithText(text:currentText, pageNumber: pageNumber) { [weak self](error, photos) in
            if let strongSelf = self {
                guard let count = photos?.count else {
                    strongSelf.showErrorAlert(message: "")
                    return
                }
                if error == nil && (photos?.count)! > 0 {
                    for photo in photos! {
                        strongSelf.photosArray.append(photo)
                    }
                    let finalList = strongSelf.list.filter { $0 != strongSelf.currentText}
                    strongSelf.list = finalList
                    strongSelf.list.insert(strongSelf.currentText, at: 0)
                    DispatchQueue.main.async(execute: { () -> Void in
                        strongSelf.insertMore()
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
}
