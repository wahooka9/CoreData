CoreData Swift



I hardly program in swift,  So some of my code could be more 'swifty'   None of this code is meant to be production quality, it is meant to show some ways on how the stack can be set up and how the stack functions. (for both Objective C and swift)


Because swift is a new language you often see totally different styles and there is the whole 'perl' mentality where some people try to get functionality to work in one line of code.  I have been coding in C++, Java, and Objective C for a long time so i have a very C style way of coding. 

I will try to be as 'swifty' as i can,  but that being said - i have a lot to learn and until i work with a group of others that program in swift and i can learn proper conventions i would in no way rely on this being  'The best way' .. as best it is most likely 'a way'  


Note:   -  The code is all in the view controller -  I normally would pull it out and make things look nice however this is more 'how to do it',  so i will avoid pruning for now. 




Core Data in Swift 
--------------------------
--------------------------

The Models
	I use the auto generate code from the CoreData Object Model -  this will give you 4 files.  What i do is i copy the NSManaged  (Core data's property) over.

	Also the entity being a string could be fixed up.  So i create an interface / protocol that every MOM will follow,  then doing this i can extend the context to accept any of the protocols types and will insert an object into that contest with the entity name. 

	Lastly i dislike all the Casting when setting properties or values for the Keys in coredata.  Because CoreData uses KVC (Key Value Coding) if we are to set a value in our managedObject,  we have to cast it.    To get rid of that case we can simply setValue for key 




NSPersistentContainer
---------------------------
---------------------------

This is Apples answer to setting up the stack 

Lets look at something quick before jumping in

So - the setup is straightforward but how do they have the stack set up?

The view context is the context on the main thread that handles the view .  (obviously) but we have no background context property however we do have a newBackgroundContect function that returns an NSManagedObjectContext.  So we know that the call to that function will give us a new ManagedObjectContext each call unless they do some funky caching (a new MOC is created each time).   
ALSO if you read the documentation they tell you straight out that the persistentContainer is built to serialize operations. 

this gives us an idea on how we should use it.

Also the documentation says the newBackgroundContext is connected directly to the PersistentStore so we will have to merge the data, not just save to the parent context. 

That being said i'm just going to use the NSPersistentContainer <-- because it is the sibling stack, and to implement the parentChild stack all i would have to do is create my own MOC

```Swift
    let backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType);
    backgroundContext.parent = persistentContainer.viewContext
```

once again i am skipping over the 
```Swift
tableView.beginUpdates()
tableView.endUpdates()
```

SOoooOOooOOoo

Let's skip the boring stuff i did with objective C and get right into some fun stuff!!

Here we will cover -  

Searching
Async Fetching 
Batch Update


Searching -

Here i added a "random" string i get from Permuting the String "LaSErBeAmZ"  and then selecting from that permuted list one of the strings for each of the cards randomly.

Then we have a super long complex predicate !!!  because it happens too quick if i don't.  

Let's take a quick look at the Predicate !!!

(random contains[cd] %@ AND random contains[cd] %@ AND random contains[cd] %@ ) or   x3

so the 'c' in [cd] means case insensitive -  and the 'd' in mean diacritic insensitive -  so it ignores accents (i don't need to worry about it anyway i just wanted to require more processing)

so -  i check for 3 strings that follow a pattern   OR another 3 strings the follow a pattern x3

Simple huh?

why dont i go into crazy search algorithms and how to speed up queries with indexing and get into queries?   Well because without making the database over a million objects-  it can effectively search for the queries in less than 10 seconds. (1.6 million took 4.2 seconds) 

I personally have never had to do any 'magic' to speed up queries for Core Data.  That being said -  I have Indexed columns and modified case to avoid case sensitivity for queries. 

If your application is running slow you can use the SQL debug mode and review the queries being called along with the execution time to index tables. 



Async Fetching -  
This can be a little bit of a pain in the butt to do your first time -  well its easy to do but to get regular updated while it is still running has to be set up properly.

So for Async Fetching we have that large Search predicate and we set the FetchRequest into a NSAsynchronousFetchRequest with a completion handler that will run when the query finishes. from there you can simply 

```Swift
	try context.execute(asyncFetchRequest)
```

and it will run.

Async Fetch with Updates !!

if we change our execute to 

```Swift 
	let result = try self.persistentContainer.viewContext.execute(async) as! NSPersistentStoreAsynchronousResult
```

NSPersistentStoreAsynchronousResult will give us access to a Progress variable.  The trouble with it is that it needs a previous invocation of becomeCurrent <-- in which case the 'Progress' is associated with that thread.  What does it all mean?   do things in the right order and where you know what thread everything is on.

Once you get things in the right order it is simple. 


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

Now what we can do is observe the value in the progress and we can tell any time it is updated.

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


Some notes 

Even know we have to keep 'threads' in mind -  The Async fetch request is not happening on the main thread even know we call it on the viewContext.   If we use the profiler we can see that a worker thread is spawned and we use that to perform the fetch. 

When the Fetch is completed it will be passed back to the main thread (for the viewContext)  or stay on a background thread (for the background context) -  When the fetch completes on the background thread the block / closure has is sometimes different than the thread the context was on.  




Batch Updates :

This is the Last thing I am going to talk about on the topic of Core Data and it is one of those topics where it's kind of like running with scissors.  Doing Batch Updating and messing with some of the settings i have corrupted my database once. I have no clue how or what happened it kind of just said "I'm not going to work for you anymore"  since i get things tweaked i haven't had any problems.

OK,  Onto the batch update!!

So - You can actually batch update and delete -  and while working with it you bypass the Core Data layer and interact with the database directly.  This means it will run FASTER and use less memory. but it also means the Snapshot / object graph will not be updated so you can run into problems and cause crashes.

If you dont need to worry about the context and just want to run a batch update quickly you can just 


```Swift
		let fetch = NSBatchUpdateRequest(entityName: "Card")
        fetch.propertiesToUpdate = ["random": ""]
        do {
            try self.persistentContainer.newBackgroundContext().execute(fetch)
        } catch { }
```

Thats it!   However there is a problem -  99% of the time you are going to want to update your snapshot so you will need to inform the context of your changes. Thats where the objectID Array comes in.

```Swift
fetch.resultType = .updatedObjectIDsResultType
```

By specifying you want the list of updatedObjectIds you can then 

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
the batch delete half took half a second. 
