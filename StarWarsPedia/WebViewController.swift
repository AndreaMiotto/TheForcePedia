//
//  WebViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 24/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    //--------------------
    //MARK: - Outlets
    //--------------------
    
    @IBOutlet weak var webView: UIWebView!
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    ///contains the resource to search into the google images library
    var stringToSearch: String!
    
    ///the base url to search through google images
    let baseURL = "http://www.google.com/images?q=Star+Wars+"
    
    ///the query string to search
    var queryString: String {
        get {
            let query = String(stringToSearch.characters.map {
                $0 == " " ? "+" : $0
            }).folding(options: .diacriticInsensitive, locale: .current)
            return query
        }
    }
    
    //--------------------
    //MARK: - View's Methods
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: baseURL + queryString);
        let requestObj = URLRequest(url: url!);
        webView.loadRequest(requestObj as URLRequest);
    }

    //--------------------
    //MARK: - Actions
    //--------------------
    
    ///Dismiss the view controller
    @IBAction func searchDone(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}

