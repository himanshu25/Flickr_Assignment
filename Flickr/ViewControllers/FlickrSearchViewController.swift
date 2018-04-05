//
//  FlickrSearchViewController.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrSearchViewController: UIViewController, UISearchBarDelegate, SearchListViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
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
    var cellsPerRow: Int = 2
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    var pageNumber = 1
    
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
        searchBar.placeholder = "Please enter some text..."
        hideCollectionViewAndIndicator()
        addNotificationObserver()
        setupDataSourceAndDelegate()
        setCellsPerRow()
        guard let selectedText = selectedText  else { return }
        searchBar.text = selectedText
        searchBarSearchButtonClicked(searchBar)
    }
    
    func saveSearchedText() {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "FlickrSearch", in: context)
        let record = NSManagedObject(entity: entity!, insertInto: context)
        record.setValue(currentText, forKey: "text")
        record.setValue(4, forKey: "time")
        do {
            try context.save()
        } catch {
        }
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
        searchBar.delegate = self
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView?.contentInsetAdjustmentBehavior = .always
    }
    
    @IBAction func historyItemTapped(_ sender: UIBarButtonItem) {
        list.removeAll()
        let moc = getContext()
        NSEntityDescription.entity(forEntityName: "FlickrSearch", in: moc)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FlickrSearch")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try moc.fetch(request)
            for data in result as! [NSManagedObject] {
               let text =  data.value(forKey: "text") as! String
                list.append(text)
                list.reverse()
            }
        } catch {
        }
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

    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
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
        if let enteredText = searchBar.text {
            currentText = enteredText
            getNextPage(pageNumber: 1)
            saveSearchedText()
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
                        strongSelf.photosArray.append(photo)
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        strongSelf.insertMoreIndexPath()
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
    
    // Paging
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == photosArray.count - 1 {
            moreData()
        }
    }
    
    func moreData() {
        pageNumber += 1
        getNextPage(pageNumber: pageNumber)
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
