//
//  PersistantCoordViewController.swift
//  CoreDataExampleSwift
//
//  Created by Andrew Riznyk on 7/30/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

import UIKit
import CoreData

class PersistantCoordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var progress : Progress!
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var progressOutlet: UIProgressView!
    
    var fetchRequest : NSFetchedResultsController<NSFetchRequestResult>!
    var background = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType);
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true;
        container.viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try container.viewContext.setQueryGenerationFrom(NSQueryGenerationToken.current)
        } catch {}
        return container
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "CardCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: cellReuseIdentifier)
        
        background.parent = persistentContainer.viewContext

        fetchData()

        tableView.reloadData()
        
    }
    
    func fetchData() {
        DispatchQueue.main.async {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
            request.fetchBatchSize = 20
        
            var array = [NSSortDescriptor]()
            array.append(NSSortDescriptor(key: "deck.deckID", ascending: true))
            array.append(NSSortDescriptor(key: "type", ascending: true))
            array.append(NSSortDescriptor(key: "number", ascending: true))
        
            request.sortDescriptors = array;
        
            self.fetchRequest = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil);
        
            do {
                try self.fetchRequest.performFetch()
            } catch {
            
            }
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CardCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CardCell
        let card : Card = fetchRequest.object(at: indexPath) as! Card
        
        cell.cardNumber.text = "\(card.number)"
        cell.cardType.text = "\(card.type)"
        cell.deckID.text = "\(card.deck_id)"
        if let rand = card.random {
            cell.randomStringLabel.text = rand
        } else {
            cell.randomStringLabel.text = ""
        }
        return cell;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let fr = fetchRequest {
            return fr.sections!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchRequest.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
            break
        default:
            break
        }
    }
    
    @IBAction func createAction(_ sender: Any) {
        let data = CardGen.createDecksAndCardsJson()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            guard let list = jsonObject as? [[String:AnyObject]] else {
                return
            }
            
            let moc = persistentContainer.newBackgroundContext()

            moc.perform {
                for deck in list {
                    let deckMOC = moc.insertDeck(deckID: deck["deckID"] as! Int, name: "")
                    let cards : [[String:AnyObject]] = deck["cards"] as! [[String : AnyObject]]
                    for card in cards {
                        let cardMOC : Card = moc.insertObject()
                        cardMOC.setValue(card["cardID"], forKey: "cardID")
                        cardMOC.setValue(card["deckID"], forKey: "deck_id")
                        cardMOC.setValue(card["type"], forKey: "type")
                        cardMOC.setValue(card["cardNumber"], forKey: "number")
                        cardMOC.setValue("", forKey: "random")
                        cardMOC.deck = deckMOC
                        deckMOC.addToCards(cardMOC)
                    }
                }
                do {
                    try moc.save()
                } catch { }
                self.fetchData()
            }
        } catch {  }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        findWithAsync()
    }
    
    
    
    @IBAction func batchAction(_ sender: Any) {
        let fetch = NSBatchUpdateRequest(entityName: "Card")
        fetch.propertiesToUpdate = ["random": ""]
        fetch.resultType = .updatedObjectIDsResultType
        do {
            let result = try self.persistentContainer.viewContext.execute(fetch) as? NSBatchUpdateResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSUpdatedObjectsKey : objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.persistentContainer.viewContext])
            self.fetchData()
        } catch {
             fatalError("Failed to perform batch update: \(error)")
        }
    }
    
    @IBAction func addStringAction(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            let list = self.permute(items: "LaSErBeAmZ".characters).map( { String.init($0) } )
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
            let moc = self.persistentContainer.newBackgroundContext()
            moc.perform {
                do {
                    let cardList : [Card] = try moc.fetch(fetch) as! [Card]
                    for card in cardList {
                        card.random = list[Int(arc4random()) % Int(list.count)]
                    }
                    try moc.save()
                } catch { }
                 self.fetchData()
            }
        }
    }
    
    
    func permute<C: Collection>(items: C) -> [[C.Generator.Element]] {
        var scratch = Array(items)
        var result: [[C.Generator.Element]] = []
        
        // Heap's algorithm
        func heap(n: Int) {
            if n == 1 {
                result.append(scratch)
                return
            }
            for i in 0..<n-1 {
                heap(n: n-1)
                let j = (n%2 == 1) ? 0 : i
                swap(&scratch[j], &scratch[n-1])
            }
            heap(n: n-1)
        }
        heap(n: scratch.count)

        return result
    }

    
    func findWithAsync(){
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        fetch.predicate = NSPredicate(format: "(random contains[cd] %@ AND random contains[cd] %@ AND random contains[cd] %@ ) or (random contains[cd] %@ AND random contains[cd] %@ AND random contains[cd] %@ ) or (random contains[cd] %@ AND random contains[cd] %@ AND random contains[cd] %@ ) or (random contains[cd] %@ AND random contains[cd] %@ AND random contains[cd] %@ ) or (random contains[cd] %@ AND random contains[cd] %@ AND random contains[cd] %@ )", "la", "ez", "sr", "se", "lz", "ra", "as", "br", "zm", "lm", "ar", "ze", "be", "am", "la")
        
        let async = NSAsynchronousFetchRequest(fetchRequest: fetch) { (results) in
            print("completed")
        }
        

        self.persistentContainer.viewContext.perform {

            do {
                let progress = Progress(totalUnitCount: 1)
                progress.becomeCurrent(withPendingUnitCount: 1)

                let result = try self.persistentContainer.viewContext.execute(async) as! NSPersistentStoreAsynchronousResult
                
                progress.resignCurrent()
                
                if let asynchronousFetchProgress = result.progress {
                    asynchronousFetchProgress.addObserver(self, forKeyPath: #keyPath(Progress.completedUnitCount), options: NSKeyValueObservingOptions.new, context: nil)
                }
            } catch { }
        }
      

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(Progress.completedUnitCount) {
            let workItem = DispatchWorkItem(block: { [weak self] in
                    //var progress = object as! Progress
                    print("update progress")
            })
            
            DispatchQueue.main.async(execute: workItem)
        
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        ///////////////// Child Context //////////////////////////
        
//        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Deck")
//            background.perform({
//                do {
//                    let results = try self.background.fetch(fetch)
//                    for object in results as! [NSManagedObject] {
//                        self.background.delete(object)
//                    }
//                    try self.background.save()
//                    try self.persistentContainer.viewContext.save()
//                } catch {
//                print(error)
//                }
//   
//                    self.fetchData()
//            
//            })
        
        ///////////////// Sibling Context //////////////////////////
//        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Deck")
//        let backgroundContext = self.persistentContainer.newBackgroundContext()
//        backgroundContext.automaticallyMergesChangesFromParent = true;
//        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump;
//        backgroundContext.perform({
//            do {
//                let results = try backgroundContext.fetch(fetch)
//                for object in results as! [NSManagedObject] {
//                    backgroundContext.delete(object)
//                }
//                try backgroundContext.save()
//                
//            } catch {
//                print(error)
//            }
//            
//            self.fetchData()
//            
//        })
        
        ///////////////// Batch Delete //////////////////////////
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Deck")
        let fetch = NSBatchDeleteRequest(fetchRequest: deleteRequest)
        fetch.resultType = .resultTypeObjectIDs
        do {
            let context = self.persistentContainer.viewContext
            let result = try context.execute(fetch) as! NSBatchDeleteResult
            guard let objectIDs = result.result as? [NSManagedObjectID] else { return }
            
            let changes = [NSUpdatedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            
            self.fetchData()
        } catch {
                
            }
    }
    
}


extension NSManagedObjectContext {
    
    func insertCard(cardID : Int?, deckID: Int?, type:Int?, number:Int?,random:String? = "") -> Card {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Card", into: self)
        entity.setValue(cardID, forKey: "cardID")
        entity.setValue(deckID, forKey: "deck_id")
        entity.setValue(type, forKey: "type")
        entity.setValue(number, forKey: "number")
        entity.setValue(random, forKey: "random")
        return entity as! Card;
    }
    
    func insertDeck(deckID:Int, name:String) -> Deck {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Deck", into: self)
        entity.setValue(name, forKey: "name")
        entity.setValue(deckID, forKey: "deckID")
        return entity as! Deck;
    }
    
    func insertObject<A: ManagedObjectType>() -> A  {
        guard let obj = NSEntityDescription
            .insertNewObject(forEntityName: A.entityName,
                                into: self) as? A else {
                                                fatalError("Fix CoreData Model Objects")
        }
        return obj
    }
}

