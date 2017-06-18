//
//  DataStore.swift
//  StarWarsPedia
//
//  Created by Andrea Miotto on 06/06/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit
import CoreData

//--------------------
//MARK: - Result Types
//--------------------

enum PersonsResult {
    case success([Person])
    case failure(Error)
}


//--------------------
//MARK: - Error Types
//--------------------

enum PersonError: Error {
    case personCreationError
}

class DataStore {
    
    //--------------------
    //MARK: - Properties
    //--------------------
    
    private  let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    let persistentContainer: NSPersistentContainer = {
        //Create a Persistent Conainer with a name, name is = as the CoreData Model
        let container = NSPersistentContainer(name: "StarWarsPedia")
        //Load the store, by default is a SQLite database
        //it's async 'cose it needs time
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        })
        return container
    }()

    
    //--------------------
    //MARK: - Person Methods
    //--------------------
    
    /*
    verifico che una risorsa esiste già con una scansione per risorse.url == url,
    importare controllare la data di modifica, ma questo mi costringe a ricaricare la risorsa.
    probabile evitare
    e magari creare una funzione update che per ogni risorsa mi controlla la data di modifica
    
    Quando creo una risorsa matematicamente creo anche le risorse associate
    si instaura una reazione a catena che mi crea moltissime risorse (forse anche tutte)
    potrebbero esserci conflitti
    
    func richiediTuttleLeRisorseDiUnTipo(tipo, contesto) {
        creo richiesta base
        contPagina: Int? = 1
        do {
            richiediRisorsePerPagina {
                per ogni risorsa {
                    //verifico che non sia già presente in DB
                    se non è presente la creo, quindi {
                        creazione
                        aggiungo attributi
                        salvo qui o solo dopo?
                        per ogni relazione {
                            controllo che l’entità non sia già presente
                            altrimenti scarico l’entità associata e la inserisco nel db
                            aggiungo la relazione
                        }
                        salvo solo qui o anche prima ?
                    }
                }
            }
            contPagina = Int(nextPage)
        } while (contPagina != nil)	
    }
 */
    
    ///Fetch all persons from CoreData
    func fetchAllPersonsFromDB(completition: @escaping (PersonsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Person.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPersons = try viewContext.fetch(fetchRequest)
                completition(.success(allPersons))
            } catch {
                completition(.failure(error))
            }
        }
    }
    
    
    ///Fetch all the persons from the web Service (SWAPI)
    func fetchAllPersonsFromAPI(fromURL url:URL? = nil, completion: @escaping (PersonsResult) -> Void) {
        
        let request: URLRequest
        
        if let url = url {
            //Make a request with the url passed through
           request = URLRequest(url: url)
        } else {
            //Make a request with the SWAPI url
            let url = SWAPI.allPersonsURL
            request = URLRequest(url: url)
        }
        
        print(url?.absoluteString)
        
        
        //create an istance of URLSessionTask
        //by giving the session a request and a completion closure
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let res = response as! HTTPURLResponse
            
            //Debug outputs
            print(res.statusCode)
            //----
            
            self.processPersonsRequest(data: data, error: error) { (result, NextPageURL) in
                OperationQueue.main.addOperation {
                    
                    //if there is a next page
                    if let url = NextPageURL {
                        //make another request with the next page url
                        self.fetchAllPersonsFromAPI(fromURL: url, completion: completion)
                    }
                    
                    completion(result)
                }
            }
        }
        
        
        //start the web service request
        task.resume()
        
    }
    
    
    
    //Process the request to the API, returns a PersonResult object and an URL if there is a "next page" with the next page URL
    private func processPersonsRequest(data: Data?, error: Error?, completion: @escaping (PersonsResult, URL?) -> Void ) {
        guard let jsonData = data else {
            completion(.failure(error!), nil)
            return
        }
        
        //The following request is made in the background queue
        //beacuse it's an expensive task
        
        
        //create a background context
        persistentContainer.performBackgroundTask { (context) in
            
            //still convert the json data
            let result = SWAPI.persons(fromJSON: jsonData, into: context)
            
            let personResult = result.0
            let nextURL = result.1
            
            //try to save the context (still the background)
            do {
                try context.save()
            } catch {
                print("Error saving the Core Data: \(error).")
                completion(.failure(error), nil)
                return
            }
            
            //now we need to bring the context result into the main queue
            //to do that we extract the object identifier for each entity in the bg queue
            //than we create a reference with the entities in the main queue
            //and we call the completion closure on the referenced entities
            //of the main queue
            
            switch personResult {
            case let .success(persons):
                let personIDs = persons.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextPersons =  personIDs.map { return viewContext.object(with: $0) } as! [Person]
                completion(.success(viewContextPersons), nextURL)
            case .failure:
                completion(personResult, nextURL)
            }
        }
    }

    
    //--------------------
    //MARK: - Helpers
    //--------------------

}











