//
//  ViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 18/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var store: DataStore!
    var people = Set<Person>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        store = DataStore()
        
        
        store.fetchAllPersonsFromAPI() { (personsResult) in
            switch personsResult {
            case let .success(persons):
                self.people = self.people.union(persons)
                print(self.people.count)
            case .failure(_):
                self.people.removeAll()
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}
