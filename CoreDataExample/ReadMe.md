Core Data / SQLite3  iOS

Heads up!  I’m dyslexic and not the best communicator - so things may be worded a bit funky

Topics
    Asynchronous World

    Tools - Instruments

    Fetching
        Faulting
        Request
        Predicate
        NSExpression
        Async Fetching
        Find or Create
    Batching


App - 
The app is setup to give you Decks of cards - For the most part the data will look like this
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



Stacks
----------------------------
----------------------------

Single Context Stack   - Everything done on the main thread.

Parent Child Context -  The Persistent Coordinator is connected to the Main Thread context and that context is the parent of the write context.

Private-Main-Private -  An additional Private context is setup to handle the write to the Persistent store. 

Sibling Context -  A private and a main context connected to the Persistent coordinator. 

SQLite 3 -    simple setup of SQLite - We will cover some topics on how to speed things up.



Single Context - 
---------------------------------------
---------------------------------------

The Single Context for Core Data is fine for 99% of cases. 

For this project I am going to Ignore the changes to the View Controller and focus just on running times of Core Data.

For Optimizing running times - One of your biggest helpers is the Timer Profiler - It will give you the running time of each function. 


1.)   RepoControllerSingle cardWithID:

This is a process to look up if the card already exists and if it does we will update it , else we want to create a new one.  Checking if a value Exists and updating or inserting is takes a lot of time.
  
The fastest way to create all the objects is going to be simply creating each object without looking to see if it already exists.

Let's pretend we are tracking a party planner.  And we want to know what people attend each party.   
If a new object is created for each person there 
    May be duplicate objects in the database.  
    Depending on how the data is provided it may be broken into sections. 

Example data from a server:

Deck :

[{
    id : 0,
    name : 0
},
{
    id : 1,
    name : 1
}]


Card:

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



Looking up the object by ID is much faster than looking up the object by a property, but the ID's supplied by the ManagedObject is Temporary and will change when the object gets saved.  So unless we fetch every object and place it into our Hashmap after saving our context the ID will be incorrect.

The way to solve this insert / update problem is to fetch objects in teh range we are inserting and sort them along with our objects. This allows us to fetch once - and check by comparing each property by index to see if the object exists. 

My method for doing this is called
```Objective-C
-(void)parseDataFaster:(NSArray*)decks;
```

2.)  RepoControllerSingle save 

After Fixing the Update or Insert functionality - RepoControllerSingle save is responsible for 99% of the process.
By saving objects in bulk rather than after each creation it will lower the time it takes for 1000 objects from 36 seconds to 1.8 seconds.



Parent-Child context
---------------------------------------
---------------------------------------

I am going to add -com.apple.CoreData.SQLDebug 1 to the schemes arguments on top of the timing profiler.


The basic Implementation takes 2 minutes to run.

[NSFetchedResultsController indexPathForObject:] is once again taking up TONS of processing. 

It is still locking because when the background context saves it then updates the main context over, and over, and over.  

So what is happening is that the Child context creates a large list of the inserted and updated objects it loops through and copies it to the parent.  Then it loops through the deleted objects and removes them.  It does this for all object even if the parent doesn't need the object data.

Not only that,  things are being held up when writing to the disk. This is because while writing to disk is being handeled by the main thread. 


Private-Main-Private
---------------------------------------
---------------------------------------

The idea of this Stack is to save to the PersistantStore and not hold up the main thread.  It still has some of the problems with the Parent child context  -  When moving data from one context to another the data actually loops and has to perform several loops to complete. First adding all the objects and then going through again to check for deletions.   

The Parent-Child context main flaw is this.  Both models lock the UI thread because of the transferring context.


Siblings
---------------------------------------
---------------------------------------

This method uses less memory and is faster. 

Lets look at this  Open up the timer profile and you can see the creation of the data and the writing and displaying it take 17.5% of the main thread and the rest runs in the background.  and let's go back to the private - main - private stack.    the main thread uses 60%.  
This is because the notification that merges the two contexts is handeled differerently than the saveing of the context.

So the context takes up space -  and adding to that context takes up space. If we issue a 'reset' on the context that context then empties,  so we can keep emptying the context and adding what we want to write to keep the core data memory small. 

Having one reset at the end of our block / closure uses 84 megs  
If we add a reset every 'deck' our memory usage drops to 44 megs.

another way to conserve memory is to refault an object. -  execute refreshObject: mergeChanges: on the context. - faults the object, Basically its a placeholder.

(lldb) po [decks[0] cards]
Relationship 'cards' fault on managed object (0x61800009c2a0) <Deck: 0x61800009c2a0> (entity: Deck; id: 0xd000000009e00002 <x-coredata://D012AC43-3DA6-4F33-B572-65C613D3EACC/Deck/p632> ; data: {
    cards = "<relationship fault: 0x60000002f4a0 'cards'>";
    deckID = 0;
    name = 0;
}) 

The cards are faulted in data.  It says 'im here but you cant see me'

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

The data is present and can be seen.

Faulting is a way to avoid loading the data into memory. This will save memory however if you try to view these properties core data will perform a fetch to grab the properties of that data.

You can also set the fetch to only grab specific properties or none at all with setIncludesPropertyValues and propertiesToFetch ,   once again if you try to access a properity that you did not pull in, a separate fetch will be executed and can make things take time.

SQLite
---------------------------------------
---------------------------------------

This is my preferred way to store data on an application -  SO IM BIAS  Proceed with caution. 

So,  right now our siblings insert takes 16 seconds to insert 560000 cards and SQLite takes ...... 6 minutes WAIT WHAT?!?!?!  who would use SQLite ?  Well my friend My inserting was Naive -  just like my first pass are setting up the core data stacks. 

Improvements:

1.) Prepared Statements 
So This is a huge improvement because when create a statement the parser only needs to run over it once.  
"INSERT INTO card (id, deck_id, number, type) values (?, ?, ?, ?)" <- now i only need to tell the statement what the value is for each insert.

2.) Transactions
This is a way of saying  write these objects all at once.  and is defined by the "BEGIN TRANSACTION" and "COMMIT TRANSACTION" in the execute SQL,

Let's try running it again with these improvements.
3.6 seconds  

The data takes up 70 Megs   
The way we can fix this is by implementing something like the FetchController.

The FFC (fake fetch controller) is a crude fetch controller.  And its broken,  It works in one direction however it illustrates the point - 

Do not want to use limit ranges in your query because when you get to larger set such as the 10  results 10000 in the SQL will fetch 10010 results and return 10.

Besides that i have a recycling array that alternates data.  The problem is that i have 3 sort fields and i could tweek it and get it to work but as it stands its a basic representation on what to do. 

SQLite is awesome and i haven't even scratched what you can do with it,  and its amazingly fast, but it can be difficult to work with

When i get around to it i will go over SQLite More in depth (I Hope)


Good luck with your Core Data - 



