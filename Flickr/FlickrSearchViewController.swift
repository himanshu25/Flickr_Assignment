//
//  FlickrSearchViewController.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import UIKit

class FlickrSearchViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, SearchListViewControllerDelegate {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var photosArray = [FlickrPhoto]()
    weak var searchListVC: SearchListViewController?
    @IBOutlet weak var spacingForSearchBar: NSLayoutConstraint!
    @IBOutlet weak var emptyImageStackView: UIStackView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var list = [String]()
    var selectedText: String?
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    let notificationCenter = NotificationCenter.default

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
        indicator.isHidden = true
        imageCollectionView.isHidden = true
        addNotificationObserver()
        setCellsPerRow()
        setupDataSourceAndDelegate()
        guard let selectedText = selectedText  else { return }
        searchBar.text = selectedText
        searchBarSearchButtonClicked(searchBar)
    }
    
    func addNotificationObserver() {
        notificationCenter.addObserver(self, selector: #selector(FlickrSearchViewController.keyboardWasShown(notification:)), name: .UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(FlickrSearchViewController.keyboardWasShown(notification:)), name: .UIKeyboardDidChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: #selector(FlickrSearchViewController.keyboardWillBeHidden(notification:)), name: .UIKeyboardDidHide, object: nil)
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
            FlickrManager.sharedInstance.getPhotosWithText(text: enteredText) { [weak self] (error, photosArray) in
                if let strongSelf = self {
                    guard let count = photosArray?.count else {
                        strongSelf.showErrorAlert(message: "")
                        return
                    }
                    if error == nil && (photosArray?.count)! > 0 {
                        strongSelf.photosArray = photosArray!
                        let finalList = strongSelf.list.filter { $0 != enteredText}
                        strongSelf.list = finalList
                        strongSelf.list.insert(enteredText, at: 0)
                        DispatchQueue.main.async(execute: { () -> Void in
                            strongSelf.indicator.isHidden = true
                            strongSelf.imageCollectionView.isHidden = false
                            strongSelf.title = searchBar.text ?? ""
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrSearchCell", for: indexPath) as! SearchCell
        cell.setupWithPhoto(flickr: photosArray[indexPath.row])
        return cell
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
    
    @objc func hideAccessoryView(_ sender: AnyObject) {
        searchBar.resignFirstResponder()
    }
    
    @objc func keyboardWasShown(notification: Notification){
        let userinfo = notification.userInfo
        let keyboardSize = (userinfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: (keyboardSize?.height)!, right: 0)
        imageCollectionView.contentInset = edgeInsets
        
    }
    @objc func keyboardWillBeHidden(notification: Notification){
        let zeroInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        imageCollectionView.contentInset = zeroInsets
    }
    
    private func showErrorAlert(message: String) {
        indicator.isHidden = true
        imageCollectionView.isHidden = true
        let alertController = UIAlertController(title: "Search Error", message: !message.isEmpty ? message : "Tha data couldn't be read because it isn't in the correct format." , preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
