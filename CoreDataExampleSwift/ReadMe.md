CoreData Swift


I hardly program in swift,  So some of my code could be more 'swifty'   None of this code is meant to be production quality, it is meant to show some ways on how the stack can be set up and how the stack functions.

Note:   -  The code is all in the view controller -  I normally would pull it out and make things look nice however this is more 'how to do it',  so i will avoid pruning for now. 

Also - I am dyslexic, and lacking in communication skills - so I may word things strangely 

Core Data in Swift 
--------------------------
--------------------------

The Models
    
	Besides the KVC (Key Value Coding) variables sometimes implementing some helper functions / variables.  




NSPersistentContainer
---------------------------
---------------------------

This is Apples answer to setting up the stack 

The view context is the context on the main thread (UI Thread).
newBackgroundContext function that returns an NSManagedObjectContext on a background thread.

newBackgroundContext is connected directly to the PersistentStore so we will have to merge the data, not just save to the parent context. 

To automatically merge the data we can set  automaticallyMergesChangesFromParent to true please note you will have to set the merge policy or else it will not work.

To set up a parent child relationship  we can
```Swift
    let backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType);
    backgroundContext.parent = persistentContainer.viewContext
```

Searching
---------------------------
---------------------------

To implement a search i added a string to each card -  This string is created by selecting a random permutation of the string "LaSErBeAmZ"

We need to create a complex search - because if we do not it will complete too quickly.


Let's take a quick look at the Predicate !!!

```swift
random contains[cd] %@ AND random contains[cd] %@ AND random contains[cd] %@ 
```

The 'c' in [cd] means case insensitive -  and the 'd' in mean diacritic insensitive -  (it ignores accents)

CoreData can effectively search for the queries in less than 10 seconds. (1.6 million took 4.2 seconds) 
If your application is running slow you can use the SQL debug mode and review the queries being called along with the execution time to index tables. 


Async Fetching
---------------------------
---------------------------

With that large Search predicate and if we set the FetchRequest into a NSAsynchronousFetchRequest with a completion handler. You can simply 

```Swift
	try context.execute(asyncFetchRequest)
```
If we change our execute to 

```Swift 
	let result = try self.persistentContainer.viewContext.execute(async) as! NSPersistentStoreAsynchronousResult
```

NSPersistentStoreAsynchronousResult will give us access to a Progress variable.  The trouble with it is that it needs a previous invocation of becomeCurrent <-- in which case the 'Progress' is associated with that thread.

```Swift
        self.persistentContainer.viewContext.perform {
            do {
               let progress = Progress(totalUnitCount: 1)
                progress.becomeCurrent(withPendingUnitCount: 1)

                let result = try self.persistentContainer.viewContext.execute(async) as! NSPersistentStoreAsynchronousResult
                
                progress.resignCurrent()
                // Add KVO here
            } catch { }
        }
```

Now observe the value in the progress and we can tell any time it is updated.

```Swift
    if let asynchronousFetchProgress = result.progress {
        asynchronousFetchProgress.addObserver(self, forKeyPath: #keyPath(Progress.completedUnitCount), options: NSKeyValueObservingOptions.new, context: nil)
    }
```

.new is 'when the value changes what is that new value'  

we are observing the progress on the  NSPersistentStoreAsynchronousResult with `self` and with the notification 'key' Progress.completedUnitCount which is a way of just having the string "completedUnitCount"  as the identifier


The downside to KVO has been the same for years -  It all gets sent to the same function - 

```Swift
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
	}
```

Seems simple enough for this small application however when using a lot of KVO you end up having to 'check' for a lot of 'keys' or contexts.  In the KVO notification you are passed the object so you can basically just parse out the data and update accordingly - 

UPDATE :
KVO has been improved in Swift 4.  


Some notes 

    The Async fetch request is not happening on the main thread even know we call it on the viewContext.   
        If we use the profiler we can see that a worker thread is spawned and we use that to perform the fetch. 

    When the Fetch is completed it will be passed back to the main thread (for the viewContext)  or stay on a background thread (for the background context) -  When the fetch completes on the background thread the block / closure has is sometimes different than the thread the context was on.  



Batch Updates
---------------------------
---------------------------

Doing Batch Updating and messing with some of the settings i have corrupted my database once.  So be careful.

You can batch update and delete 
While working with Batching you bypass the Core Data layer and interact with the database directly.  This means it will run FASTER and use less memory, However; it also means the Snapshot / object graph will not be updated so it will have to be modified accordingly.

If you dont need to worry about the context and just want to run a batch update quickly

```Swift
		let fetch = NSBatchUpdateRequest(entityName: "Card")
        fetch.propertiesToUpdate = ["random": ""]
        do {
            try self.persistentContainer.newBackgroundContext().execute(fetch)
        } catch { }
```

To update our Object Graph we will use an objectID Array.

```Swift
fetch.resultType = .updatedObjectIDsResultType
```

This will return an array of ID's the fetch has updated.  We then can process the changed objects by

```Swift
			let result = try self.persistentContainer.viewContext.execute(fetch) as? NSBatchUpdateResult
           	let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSUpdatedObjectsKey : objectIDArray]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.persistentContainer.viewContext])
```

This lets your context know the Object ID's it needs to refresh -   

Batch updating is FAST, and uses little memory,  however you are stuck setting fields to one value - 


Batch Delete :
---------------------
---------------------

The deletion of 10000 decks took Core data - with the child context 2 minutes. 
CoreData that updates directly to the persistent store coordinator took 16 seconds.
The batch delete half took less than half a second. 



