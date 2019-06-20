# Command Line Todo List 2.0


## Summary 
This exercise is a continuation of a exercise 62.  We'll take an application that meets all the requirements specified in that exercise and add some additional features.  Write the best object-oriented code we can!


## Progression
### Part 0: Review the Code Base


Did you complete writing your object oriented Todo list? Compare it with the version provided here. Think about why certain methods or certain classes are structured this way. It is recommended that you start this exercise with the version provided. If you feel that your version of Todo is better, feel free to use your own copy of todo.rb to complete this exercise.


We're provided with a working todo list application, based on the requirements of the exercise 62.  One feature is missing, because you will have to reimplement it in a different way: The ID of the items. This will be done in Part 1. We can use the application to display a list of items, add items, remove items, and mark items as complete. Run the tests and review the code.  What objects are there?  How do they work together?  Be sure to understand how the provided application works because we're going to dive into it when it's time to add new features.




### Part 1: Creation Date and Completion Date
We have an `Item` class with two attributes:  a complete status and a description.  We want to begin storing the dates when items are created and when they are completed.

So, when a new item is added to the list, we need to save the date when the item was added.  When an item is marked complete, we need to save the date when the item was completed.  How will we represent these timestamps in our data file?  How will we represent them in Ruby?  Could this change how an item determines whether or not it's complete or incomplete?

Think through how to implement this new feature.  What objects are affected?  How are they affected?  Write tests for any new behaviors and update any tests that are affected by this change.  

*Note:*  Edit the data file as necessary.


### Part 2: Display a Sorted List
Now that we're tracking when our items are created, let's update how we display the list of items.  Instead of printing them in any order, print them with their ID based on their chronological order — the newest items will have the last ID, and will be at the bottom. The oldest items will have the first ID, and will be at the top. 


### Part 3: Filter the List
When a user wants to view the list of items, our application displays every item—both completed items and incomplete items.  We are going to add a feature that allows users to display all the items, only completed items, or only incomplete items (see Figure 1).

```
$ ruby todo.rb list
1. [X] Milk the cow.
2. [ ] Gather the eggs.
3. [X] Feed the pigs.

$ ruby todo.rb list completed
1. [X] Milk the cow.
3. [X] Feed the pigs.

$ ruby todo.rb list incomplete
2. [ ] Gather the eggs.
```
*Figure 1*.  Listing options:  all, complete, and incomplete.


### Part 4: Tagging Items and Filtering by Tag
Our todo list can often contain subsections of related items:  personal items, financial items, pet-related items, etc.  We want users to be able to filter a list to show a specific group of items.

We're going to implement item tagging.  We'll be adding two new commands for running our application:  one for tagging an item and one for displaying items with a specific tag (see Figure 2).  An item can have multiple tags.

```
$ ruby todo.rb list
1. [X] Submit refund paperwork
2. [ ] Cash refund check.

$ ruby todo.rb tag 2 #bank #financial
Tagged "2. Cash refund check." with the tags #bank, #financial.

$ ruby todo.rb list #bank
2. [ ] Cash refund check.
```
*Figure 2*.  Tagging items and filtering the list by a tag.


*Note:*  Our data file might start to feel a little messy now that we're storing the complete status, description, date created, date completed, and any tags.  Try to keep the constraint that the file is human readable and is recognizable as a todo list if printed out.


## Conclusion
We had to jump into an existing code base.  Before beginning the exercise, we had to read and understand what how the existing code functions?  How was that?  Was it easy?  Overwhelming?  What have we learned about working with an existing code base?

As we added features we had to decide how to update our application.  Do we need new objects?  Should we modify existing objects?  How did we identify which object should be responsible for the new behaviors?  Do we feel good about the decisions we made?  What could we do better going forward?
