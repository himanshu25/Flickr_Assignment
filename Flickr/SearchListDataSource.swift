//
//  SearchListDataSource.swift
//  Flickr
//
//  Created by Himanshu on 05/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation

class SearchListDataSource: NSObject, UITableViewDataSource {
    var list = [String]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        cell.label.text = list[indexPath.row]
        return cell
    }
    

}
