//
//  FilmsTableViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 21/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit


class FilmsTableViewController: UITableViewController {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    //This is property is passed through segue
    var store: DataStore!
    
    var films = [Film]()
    
    //--------------------
    //MARK: - View Methods
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        self.updateDataSource()
        
        /*
        store.fetchAllFilmsFromAPI() { (filmResult) in
            self.updateDataSource()
        }
         */
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add a background view to the table view
        let imageView = UIImageView(image: #imageLiteral(resourceName: "bg_blurred"))
        self.tableView.backgroundView = imageView
    }
    
    
    //--------------------
    // MARK: - Table view data source
    //--------------------
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return films.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "filmCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = films[indexPath.row].title
        return cell
        
    }
    
    
    
     //--------------------
     // MARK: - Navigation
     //--------------------
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Edit the back button title displayed in the next vc
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        
        switch segue.identifier {
        case "showFilmDetails"?:
            if let selectedIndexPath = tableView.indexPathsForSelectedRows?.first {
                let film = films[selectedIndexPath.row]
                let destinationVC = segue.destination as! FilmDetailsTableViewController
                destinationVC.film = film
                destinationVC.store = store
            }
            
        default:
            preconditionFailure("Unexpected segue identifier.")
        }


     }
 
    
    //--------------------
    //MARK: - Methods
    //--------------------
    
    private func updateDataSource() {
        store.fetchAllFilmsFromDB { (filmsResult) in
            switch filmsResult {
            case let .success(films):
                self.films = films
            case .failure(_):
                self.films.removeAll()
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
}

