Core Data / SQLite3  iOS

One think I do as a developer is to keep Boiler plate code sitting around that i can quickly copy and paste project to project -  at the top of that list is my Core Data Stack.

Over the years Core Data has changed and honestly I have had to make changes to my stack recently to keep it relevant -  And after making changes to my stack Apple releases the PersistantStoreContainer So, some of what this will cover will be obsolete - However what I will try to add are tips and tricks to make Core Data function more efficiently in a project.  As well as covering my favorite method of persistence - SQLite 


Core Data -

So,  I broke this application into sections (Objective-C has more than Swift)

Single Context Stack   - Everything done on the main thread.

Parent Child Context -  The Persistent Coordinator is connected to the Main Thread context and that context is the parent of the write context.

Private-Main-Private -  An additional Private context is setup to handle the write to the Persistent store. 

Sibling Context -  A private and a main context connected to the Persistent coordinator. 

SQLite 3 -    simple setup of SQLite - We will cover some topics on how to speed things up.



Topics (not covered in a discernible order)
	Asynchronous World

	Tools - Instruments

	Fetching
		Faulting
		Request
		Prediate
		NSExpression
		Async Fetching
		Find or Create
	Batching


App - 
The app is setup to give you Decks of cards -  there are additional fields just for the heck of it.  for the most part the data will look like this
[{
	id : 0,
	name : 0,
	cards : [
		{
			id : 0,
			deck_id : 0,
			number : 0,
			type : 0
		}
	]
}]

The code is not production -  I am simply using it to illustrate the use of the stack
AND ITS ALL DONE IN BULK -  it would not always be like this in the real world.




Single Context - 
---------------------------------------
---------------------------------------

When people give tons of performance tips on core data and how to manage it and give you tons and tons of different models and ways of executing 99% of the time they are FULL OF CRAP! (this includes me)  What is the main reason we like to use multiple contexts?  performance?   this single context stack done correctly can write over 5000 objects in less than .3 a second.  So if you have a user pecking at the keyboard to insert data or you are inserting / updating less than 5000 items chances are you do not need anything else.  


Aside :  -  run this app and use the timer profile to see where the app is taking a lot of time to run.


Problems -  
1.)    The Fetch Results Controller 
Man these are nice because they make it easy to display data however while the context is being updated you can see that the    NSFetchedResultsController(PrivateMethods) _preprocessInsertedObjects:insertsInfo:newSectionNames:   Takes up 99.8 % of the process  so let's comment out 

```Objective C
//    [self.frc setDelegate:self];
```
alternatively we can set the tableView to beginUpdates to avoid this issue in the controllerWillChangeContent
and by endUpdates when controllerDidChangeContent ..   And remove the delegate while the fetch controller is going wild and readd it when it is done (i was feeling lazy)

2.)   RepoControllerSingle cardWithID:
This is a process to look up if the card already exists and if it does we will update it , else we want to create a new one.    In this you can see that it forces a call to  [NSManagedObjectContext executeFetchRequest:error:] 

Lets come back to this,   for now let's just create a new object with each cycle so change 

```Objective-C
[RepoControllerSingle deckWithID:deckValueID];
.
.
.
[RepoControllerSingle cardWithID:cardID];
```
To
```Objective-C
[RepoControllerSingle makeDeck];
.
.
.
[RepoControllerSingle makeCard];
```


We will come back to this.

3.)  RepoControllerSingle save 
This is the save process, it is now responsible for 99% of the process (when its saving, not creating the data) and the creation of all the objects will take around 36 seconds. (for 1000 decks) If you move it to the outside of the loop you can cut the total time to 1.8 seconds.



OK  -   Lets revisit the  RepoControllerSingle cardWithID:  <--   
The fastest way to create all the objects is going to be simply creating each object without looking to see if it already exists.  so we have the fastest implementation by creating an object directly inside of the managed object context,  but there is a problem with this design-

Let's pretend we are tracking a party planner.  And we want to know what people attend each party.   If i create a new object for each person there may be duplicate people in the database.  Not just that but sometimes you don't have a choice on how data is sent to your app so you may receive all the deck information 
[{
	id : 0,
	name : 0
},
{
	id : 1,
	name : 1
}]
and card information
[{
	id : 0,
	deck_id : 0,
	number : 0,
	type : 0
},
{
	id : 1,
	deck_id : 0,
	number : 1,
	type : 0
}]

We are then forced to look up if the data exists , and create or update based on that.   BUT ITS SOOO DAMN SLOOWWWW.

Looking up the object by ID is much faster than looking up the object by a property-  BUT -  for inserting in batches this is no good -  because the ID's supplied by the ManagedObject is Temporary and will change when the object gets saved.  SO - unless we fetch EVERY object and input it into our hashmap after the save this approach will be useless.

Pity, because the hashmap would make things BLAZING fast

What we do to perform a lookup of each object is to fetch once or fetch in batches what we plan on updating -  this made my job easy because I insert all the objects at once.  

First thing you will want to do to implement this is to sort both arrays of data - you want both the fetch data and the input data to be sorted by the id you will be checking by,  then when you iterate through you can compare an index rather than searching the array each time. 

My method for doing this is called
```Objective-C
-(void)parseDataFaster:(NSArray*)decks;
```

This makes it take O(1) more time to run -  if the batches were broken up a bit there may need to be some extra update fetch to increment the fetch array data , 

I may have missed some tweaking but we can talk about batching later -  One important note to make is the Core Data is set up to Cascade -  so if a parent is deleted then all its children are deleted like dominoes falling over.  That's why the 'Delete All' functionality just removes the Decks and it empties the Database.


Parent-Child context
---------------------------------------
---------------------------------------

The way i have this stack set up is not the best-  The idea is that we have the single context with a way to create writing context on top of it regardless of thread.  It just creates a new context and throws it out into the wild.    

AND NOW OUR HEARTS SINK -  Why ?  because we spent all this time optimizing the single core method and now we have to do it all over again.  

Now i would like to take the time and say that my core data tool is broken for Instruments soooo im stuck doing this the old fashioned way and using the timer profile, the Allocation profile, and adding -com.apple.CoreData.SQLDebug 1 to the schemes arguments.  

alright -  lets first check it out by running it 

Once again its takeing over 2 minutes to run.  

SO -  first thing i look at and see is that most of what is happening is happening on the main thread. 

And once again the FetchResults controller is requesting fetch data and the notification center is firing a 'did update' notification 

[NSFetchedResultsController indexPathForObject:] is once again taking up TONS of processing. 


Now you ask "WHAT THE HELL GUY?!?!?!  Didn't we just move everything to a background context?"

Yes,  we did.   It is still locking because when the background context saves it then updates the main context over, and over, and over.  

So what is happening is that the Child context creates a large list of the inserted and updated objects it loops through and copies it to the parent.  Then it loops through the deleted objects and removes them.  It does this for all object even if the parent doesn't need the object data and worse it calls the 'didUpdateContext' which fires the NSFetchController.    Once again we are better off not fetching 24/7 for large imports.  (for smaller stuff the fetch controller is better than fine)

I basically update the table whenever a delegate fires telling me a job / load is done.

Once again you could just add the beginUpdate and endUpdate to the tableview however because i have a timer doing the work i was lazy rather than implementing delegate methods for something im not trying to track.

Not only that,  things are being held up when writing to the disk. 

That's all i would like to cover for this implementation.   




Private-Main-Private
---------------------------------------
---------------------------------------

the fetch result controller is still acting up (yet again)  however this time the controller still loads quite a bit faster even with this.  

Anyway let's still get rid of the delegate instead of implementing the begin and end update on the tableview. 


Now a slight problem with the Xcode Threading -  Xcode says my saveContext NSPrivateQueueConcurrencyType is on the main thread (thread 1)  -  WWHHYYYY?!?!?!

MAYBE:
This happens because things are being created synchronously -  that is why the concurrency is happening on the main thread -  because the compiler says 'It won't finish any quicker anyway'

this is something i will have to look into more


Siblings
---------------------------------------
---------------------------------------

This is my favorite way to setup the core data stack -  why?    because if the data is user edited the main thread is enough to handle it. and the background persistence layer is for large jobs.  
Not only does this stack use less memory, it is also a bit faster. 

Lets look at this  Open up the timer profile and you can see the creation of the data and the writing and displaying it take 17.5% of the main thread and the rest runs in the background.  and let's go back to the private - main - private stack.    the main thread uses 60%.  

The whole idea of using the private context to save tot eh persistent coordinator was to take strain off the main thread.   Well if we break it down and read what is being ran on the phone you will see that the saves happen differently than a merge. 

I could spend a ton of time stepping through it but in the end just know that a save runs through changes then deletes (all on the main thread),  and the merge simply takes the change log of the context and applies it to the other context. 


Lets take this opportunity to talk about MEMORY!!!  

So the context takes up space -  and adding to that context takes up space. however if we issue a 'reset' on the context that context then empties,  so we can keep emptying the context and adding what we want to write to keep the core data memory small. 

so if we periodically reset the MOC we can keep memory usage low.  having one reset at the end of our block / closure uses 84 megs  however if we add a reset every 'deck' our memory usage drops to 44 megs.

There are 2 other techniques that i have not used here because resetting the context was fine,  but if you wrap objects with an autorelease block you it will release that object when it leaves scope.  And also you can refault objects.  

The way you refault an object is to execute refreshObject: mergeChanges: on the context. -  So what is a fault?   Basically its a placeholder.  if you place a breakpoint in this project on a fetch for the deck you can see that the cards (after a restart and you hit delete to fetch decks)

(lldb) po [decks[0] cards]
Relationship 'cards' fault on managed object (0x61800009c2a0) <Deck: 0x61800009c2a0> (entity: Deck; id: 0xd000000009e00002 <x-coredata://D012AC43-3DA6-4F33-B572-65C613D3EACC/Deck/p632> ; data: {
    cards = "<relationship fault: 0x60000002f4a0 'cards'>";
    deckID = 0;
    name = 0;
}) 

The cards are faulted in data.  it basically says 'im here but you cant see me'

If we fetch the deck right after creating it (without restarting the app)

po [decks[0] cards]
Relationship 'cards' on managed object (0x608000284bf0) <Deck: 0x608000284bf0> (entity: Deck; id: 0xd00000000fcc0002 <x-coredata://D012AC43-3DA6-4F33-B572-65C613D3EACC/Deck/p1011> ; data: {
    cards =     (
        "0xd000000385180000 <x-coredata://D012AC43-3DA6-4F33-B572-65C613D3EACC/Card/p57670>",
        "0xd000000375000000 <x-coredata://D012AC43-3DA6-4F33-B572-65C613D3EACC/Card/p56640>",
        "(...and 54 more...)"
    );
    deckID = 0;
    name = 0;
}) with objects {(
    <Card: 0x608000284330> (entity: Card; id: 0xd000000385180000 <x-coredata://D012AC43-3DA6-4F33-B572-65C613D3EACC/Card/p57670> ; data: {
    cardID = 39;
    deck = "0xd00000000fcc0002 <x-coredata://D012AC43-3DA6-4F33-B572-65C613D3EACC/Deck/p1011>";
    deckID = 0;
    number = 11;
    type = 2;
}),
   
   .
   .
   .
   {(
    <Card: 0x608000284920> (entity: Card; id: 0xd000000379bc0000 <x-coredata://D012AC43-3DA6-4F33-B572-65C613D3EACC/Card/p56943> ; data: {
    cardID = 20;
    deck = "0xd00000000fcc0002 <x-coredata://D012AC43-3DA6-4F33-B572-65C613D3EACC/Deck/p1011>";
    deckID = 0;
    number = 6;
    type = 1;
})
)}

you can clearly see the data is present and can be seen.

Faulting is a way to avoid loading the data into memory. This will save memory however if you try to view these properties core data will perform a fetch to grab the properties of that data.

You can also set the fetch to only grab specific properties or none at all with setIncludesPropertyValues and propertiesToFetch ,   once again if you try to access a properity that you did not pull in, a separate fetch will be executed and can make things take time.

When trying to reduce your memory imprint please realize that fetching data and sending it to your view controller will cause you to use a ton more data. and it will slow down your import BAD if you keep trying to update off of the save notifications. 



SQLite
---------------------------------------
---------------------------------------

This is my preferred way to store data on an application -  I haven't used it in a long time due to  wanting to improve my core data experience and also that core data is FAST to set up. But SQLite gives you more control, or i should say forces you to manage everything that core data just does for you. 

Lazy Heathen!!

So,  right now our siblings insert takes 16 seconds to insert 560000 cards and SQLite takes ...... 6 minutes WAIT WHAT?!?!?!  who would use SQLite ?  Well my friend My inserting was Naive -  just like my first pass are setting up the core data stacks. there are some improvements i can make.

1.) Prepared Statements 
So This is a huge improvement because when create a statement the parser only needs to run over it once.  
"INSERT INTO card (id, deck_id, number, type) values (?, ?, ?, ?)" <- now i only need to tell the statement what the value is for each insert.

2.) Transactions
This is a way of saying  write these objects all at once.  and is defined by the "BEGIN TRANSACTION" and "COMMIT TRANSACTION" in the execute SQL,

Let's try running it again with these improvements.
3.6 seconds  -  Not bad.   But when i view the data - it's taking up 70 Megs   How about we do something like the fetchcontroller?  (NO caching or fast loading -  just for an example)

The FFC (fake fetch controller) is a crude fetch controller.  And its broken,  it works in one direction however it illustrates the point -  you do not want to use limit ranges in your query because when you get to larger set such as the 10  results 10000 in the SQL will fetch 10010 results and return 10. and that would be fine for the beginning of a list but later on it gets BAD.
Besides that i have a recycling array that alternates data.  The problem is that i have 3 sort fields and i could tweek it and get it to work but as it stands its a basic representation on what to do. 

SQLite is awesome and i haven't even scratched what you can do with it,  and its amazingly fast, but it can be difficult to work with (there are logs to help with that)

When i get around to it i will go over SQLite More in depth


Good luck with your Core Data - 
