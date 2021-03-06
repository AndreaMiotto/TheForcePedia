//
//  LandingViewController.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 18/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit
import AVFoundation

class LandingViewController: UITableViewController {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    
    //This is property injection, check on
    //ApplicationDelegate.swift
    var store: DataStore!
    
    var audioPlayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        store.fetchAllPersonsFromAPI() { (personResult) in
            print("characters downloaded")
        }
        
        store.fetchAllFilmsFromAPI { (filmResult) in
            print("films downloaded")
        }
        
        store.fetchAllPlanetsFromAPI { (planetResult) in
            print("planets downloaded")
        }
        
        store.fetchAllSpeciesFromAPI { (specieResult) in
            print("species downloaded")
        }
        
        store.fetchAllStarshipsFromAPI { (starshipResult) in
            print("starships downloaded")
        }
        
        store.fetchAllVehiclesFromAPI { (vehicleResult) in
            print("vehicles downloaded")
        }
        playSound(path: "/Sounds/Hum", ofType: "mp3")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add a background view to the table view
        let imageView = UIImageView(image: #imageLiteral(resourceName: "bg_blurred"))
        self.tableView.backgroundView = imageView
    }
    
    
    //--------------------
    //MARK: - Methods
    //--------------------
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Edit the back button title displayed in the next vc
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        
        switch segue.identifier {
        case "showCharacters"?:
            playSound(path: "/Sounds/Breathing", ofType: "mp3")
            let destinationVC = segue.destination as! PersonsTableViewController
            destinationVC.store = store
            
        case "showFilms"?:
            playSound(path: "/Sounds/AcrossTheStars", ofType: "mp3")
            let destinationVC = segue.destination as! FilmsTableViewController
            destinationVC.store = store
            
        case "showPlanets"?:
            playSound(path: "/Sounds/YodaHome", ofType: "mp3")
            let destinationVC = segue.destination as! PlanetsTableViewController
            destinationVC.store = store
            
        case "showSpecies"?:
            playSound(path: "/Sounds/Jawa", ofType: "mp3")
            let destinationVC = segue.destination as! SpeciesTableViewController
            destinationVC.store = store
            
        case "showStarships"?:
            playSound(path: "/Sounds/Snowspeeder", ofType: "mp3")
            let destinationVC = segue.destination as! StarshipsTableViewController
            destinationVC.store = store
            
        case "showVehicles"?:
            playSound(path: "/Sounds/SkywalkerSpinsOut", ofType: "mp3")
            let destinationVC = segue.destination as! VehiclesTableViewController
            destinationVC.store = store
            
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    //--------------------
    //MARK: - Audio Methods
    //--------------------
    
    
    func playSound(path: String, ofType type: String) {
        let audioFilePath = Bundle.main.path(forResource: path, ofType: type)
        if audioFilePath != nil {
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioFileUrl, fileTypeHint: type)
            } catch {
                print("Error creating audio stream")
            }
            audioPlayer.play()
        } else {
            print("Audio file is not found")
        }
    }
    
}
