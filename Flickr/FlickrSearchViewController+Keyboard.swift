//
//  FlickrSearchViewController+Keyboard.swift
//  Flickr
//
//  Created by Himanshu on 05/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation

extension FlickrSearchViewController {
    
    func addNotificationObserver() {
        notificationCenter.addObserver(self, selector: #selector(FlickrSearchViewController.keyboardWasShown(notification:)), name: .UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(FlickrSearchViewController.keyboardWasShown(notification:)), name: .UIKeyboardDidChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: #selector(FlickrSearchViewController.keyboardWillBeHidden(notification:)), name: .UIKeyboardDidHide, object: nil)
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
}
