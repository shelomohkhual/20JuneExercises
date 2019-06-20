# From HTML to Ruby Objects

## Summary
We've been creating custom Ruby objects that have both *state* and *behavior*.  State is the data internal to an object—think instance variables in Ruby.  Behavior is what the object can do, and we think about behavior as the methods to which an object responds.

From where do we get the data that becomes the state of our objects? In this exercise, we're going to use a live HTML page as a data source.  We'll take a webpage and parse the markup into Ruby objects.  Extracting information from websites as we'll be doing is known as [web scraping][].

We're going to write a web scraper to grab information from [Hacker News][].  We'll translate data from Hacker News comment threads (see [example][HN Comment Thread]) into Ruby objects.  Given the technical challenges that we'll encounter, it will be easy for us to lose focus on our main goal: building custom Ruby objects based on pre-existing data.


### The Nokogiri Gem
We won't be building an HTML parser ourselves.  Instead, we'll rely on the [Nokogiri][] gem.  Nokogiri is likely an unfamiliar tool, and one of the technical challenges we'll face is simply learning how to use it.

It might feel like Nokogiri is the focus of this exercise, but it's not.  Nokogiri is a tool that we'll use to parse HTML.  We'll be passing HTML to Nokogiri, and it will translate that HTML into its own custom Nokogiri Ruby objects.  We'll take those Nokogiri Ruby objects and convert them into our objects.


## Progression
### Part 0:  Install the Nokogiri Gem
```
$ gem list nokogiri

*** LOCAL GEMS ***

nokogiri (1.6.6.2, 1.6.5, 1.6.0)
```
*Figure 1*.  Checking to see which, if any, versions of Nokogiri are installed.

Before we begin with this exercise we need to have the Nokogiri gem installed.  It should be installed on the Dev Bootcamp workstations.  If we're working on a personal machine, we can check to see which, if any, versions of Nokogiri are installed (see Figure 1).  If any versions of Nokogiri are installed, they will be listed under the local gems heading.

```
$ gem install nokogiri
```
*Figure 2*.  Installing Nokogiri from the command line.

If no versions of Nokogiri are installed, we'll need to install one (see Figure 2).  Unfortunately, installing Nokogiri does not always go smoothly.  If we run into issues, we should begin troubleshooting by referencing Nokogiri's [installation instructions][Nokogiri installation].  If we still have issues, we should seek help from an instructor.


### Part 1:  Further Explore Nokogiri
Before we begin working with the Hacker News markup, let's first build a little familiarity with Nokogiri.  As per the previous exercise, we'll use Nokogiri to parse the HMTL in the file `html-samples/example.html` into Nokogiri Ruby objects and then explore those objects a bit.

![HTML Tree](readme-assets/html-tree.png)

*Figure 3*. Tree depicting the `<body>` tag in `html-samples/example.html`.

If we look at the file `html-samples/example.html`, we can see that it's a small, simple HTML document.  Let's take a look at the `<body>` tag and the tags that are nested within it.  The `<body>` tag has one child, the `<main>` tag.  And the main tag has three children of its own:  a heading and two paragraphs.  We can think of this as a tree structure (see Figure 3).

When Nokogiri parses HTML, it returns a model of that HTML.  It returns one object, but the object has child objects, and these children have child objects of their own, etc.  When we parse `html-samples/example.html`, we'll get one object to represent the document.  It will have a child node named `'html'` that has a child node named `'body'` that has a child node named `'main'` that has child nodes named `'h1'`, `'p'`, and `'p'`.  It's the same tree structure we saw in Figure 3.

```ruby
require 'nokogiri'
# => true
load 'html_whitespace_cleaner.rb'
# => true
html = File.read('html-samples/example.html')
# => "<!doctype html>\n  <html>\n  <head> ... </html>\n"
clean_html = HTMLWhitespaceCleaner.clean(html)
# => "<!doctype html><html><head> ... </html>"
nokogiri_document = Nokogiri.parse(clean_html)
# => #<Nokogiri::HTML::Document:0x3fe7de194e38 name="document" children=[ ... ]>
html_node = nokogiri_document.children.last
# => #<Nokogiri::XML::Element:0x3fe7de1948c0 name="html" children=[ ... ]>
body_node = html_node.children.last
# => => #<Nokogiri::XML::Element:0x3fe7ddda8f90 name="body" children=[ ... ]>
main_node = body_node.children.first
# => => #<Nokogiri::XML::Element:0x3fe7ddda8db0 name="main" children=[ ... ]>
names_of_main_nodes_children = main_node.children.map(&:name)
# => ["h1", "p", "p"]
```
*Figure 4*.  Using Nokogiri to traverse the HTML tree structure.

Let's open up IRB and use Nokogiri to parse our HTML example file; follow the commands displayed in Figure 4.  The first thing we need to do is require the Nokogiri gem.  Now, when we ask Nokogiri to parse HTML for us, one type of argument we can pass is a string, which we read from our example HTML file.  We're also loading and then using a custom object, `HTMLWhitespaceCleaner` that will scrub a string to make it more Nokogiri friendly; for example, Nokogiri will create separate nodes for whitespace characters between tags—even the newline characters—and this object will clean that up for us.

We then ask Nokogiri to parse the scrubbed string for us, and Nokogiri returns a document object to us. With this object, we can begin to traverse the tree of our HTML from the document to the node representing the `<html>` tag to that node's child, and so forth.  Do we understand how to traverse this representation of our HTML from the document object through generations of children down to specific nodes?

```ruby
paragraphs = nokogiri_document.css('p')
# => [#<Nokogiri::XML::Element:0x3fe7ddda8874 name="p" ... >, #<Nokogiri::XML::Element:0x3fe7ddda8270 name="p" ... >]
```
*Figure 5*. Selecting all elements that match a CSS selector.

Sometimes we want to search for specific nodes, like all the nodes representing paragraph tags.  We could traverse all the nodes Nokogiri created and find them that way, but Nokogiri provides a more convenient method.  We can use the `#css` method with [CSS selectors][] to retrieve a set of all the nodes that match the selector.

In Figure 5, we select a set of all the Nokogiri objects that represent paragraph tags.  Let's grab some other elements.  Can we grab a set of all the objects with the class `text`?

We've walked through the basics of working with Nokogiri.  We'll learn some more as we work through this exercise.  If we get stuck, we can always return to IRB and/or use a debugger to explore the objects Nokogiri creates for us.  In addition, we can search for references online, such as The Bastard's Book of Ruby guide to [parsing HTML with Nokogiri][BBR Guide].


### Part 2: Modeling Posts and Comments
Before we can parse our HTML into Ruby objects, we have to design the Ruby objects.  We're going to write two classes that will represent a Hacker News comment thread:  a `Post` class and a `Comment` class.

If we take a look at a [comment thread][HN Comment Thread] on Hacker News, we'll see that users can post a link to another webpage.  And, we can gather information about the post:  the title, the URL to the other webpage, who posted the link, how many points the post has earned, etc.  We'll also find comments.  And, as with the post, we can find information on each individual comment:  the text of the comment, the username of the commenter, etc.

Test and develop a `Post` and `Comment` class to represent the data seen on Hacker News.  What state should each of them hold?  Do they need any behaviors?

**Requirements**
- At a minimum, a post should have these attributes ...
  - title: the title on Hacker News.
  - url: the URL to which the post points.
  - points: the number of points the post currently has.
  - author username: the username of the post's author.
  - item id: the post's Hacker News item ID.
- The relationship between posts and comments is such that a post has many comments and an individual comment belongs to one post.  We need to write at least two methods that control a post's behavior relating to its comments:
  - `Post#comments`: returns the post's collection of comments.
  - `Post#add_comment`: takes a `Comment` object as its input and adds it to the post's collection of comments. This only affects a post object in our Ruby program, it doesn't do anything to the Hacker News page.


### Part 3: Hacker News HTML to Post and Comment Objects
We've explored Nokogiri a bit and have designed `Post` and `Comment` classes.  Now it's time to take some Hacker News HTML and parse it into our Ruby objects.  To avoid repeatedly hitting the Hacker News servers and getting the DBC network temporarily banned, we'll start by scraping an HTML file that we've saved locally (see `html-samples/hacker-news-post.html`).  We will move on to parsing live webpages once we're able to successfully parse the local file.

We'll need an object to parse the HTML into our post and comment objects.  Do we already have an object that should have that responsibility?  Would it make sense to design a new object to do the parsing?  Let's ensure that we follow object-oriented principles and that we understand and can explain why we're making decisions.

We'll also want to test that our parsing is working as we expect.  Given a specific set of HTML, the object that does our parsing should create a post object with specific attributes (e.g. title, url, etc.).  The post should also have a specific set of comments.

One of the challenges in parsing the Hacker News HTML will be how to extract the information that we need.  How do we grab the username of the post's author?  The Hacker News item ID?  How do we get nodes representing all of the comments?

```ruby
# Assume the code in 'html-samples/hacker-news-post.html'
# has been parsed into a Nokogiri document object
# and stored in the variable 'nokogiri_document'.

nokogiri_document.css('.subtext > span:first-child').first.inner_text.slice(/\A\d*/)
nokogiri_document.css('.subtext > span:first-child').first.attributes["id"].value.slice(/\d*\z/)
nokogiri_document.css('.title > a').first.inner_text
nokogiri_document.css('.title > a').first['href']
```
*Figure 6*.  Pulling specific pieces of information from a Nokogiri document object.

Each of the examples in Figure 6 pulls out a piece of information that we need to build our objects.  Looking at each css selector and subsequent method chaining, can we read through the HTML and identify which piece of information each example extracts?  Run each example to confirm our thoughts and then use each example in our parsing object.

We'll need to figure out for ourselves how to get the rest of the information.  We should read through the HTML source code to figure out which selectors will lead us to the information we need.

**Tips**
```ruby
first_comment = nokogiri_document.css('.default').first
first_comment.css('.comhead a:first-child')
```
*Figure 7*. Calling the `#css` method on a specific node, not the document object.

- Each comment in the HTML is wrapped in a tag with the class `default`.
- When we use the `#css` method to search the document for nodes matching a CSS selector, any match in the document is returned.  We can also call the `#css` method on a specific node, which will narrow our search to the children, grandchildren, etc. of that specific node (see Figure 7).


### Part 4: Display a Post and its Comments
```
$ ruby driver.rb

Choosing Ruby on Rails for web development project in 2019 (Hacker News ID: 20039589)
    URL: https://www.ideamotive.co/ruby-on-rails-development-guide/?in-2019
    Author: milo_im
    Points: 194

    Comments:
    "Ruby/Rails backend with a React FE seems to be pretty popular these days, and is where I spend ..."
    - llamataboot

    "I've taken the approach of building the monolith first with an architecture that allows me to  ..."
    - mipmap04

    continued ...
```
*Figure 8*.  Example display of post and comment objects on the command line.

Once we're confident that we're able to parse a Hacker News comment thread into a post with comments, let's display the objects on the command line.  Let's update the `driver.rb` file to output a custom display of a Hacker News comment thread (see Figure 8).  For now, we'll just display the local file with which we've been working.

How will we control how posts and comments are rendered on the command line?  Is an object responsible for their presentation?  How can we test that the presentation is what we expect?

*Note:*  Our presentation of a post and comments does not need to match Figure 8.


### Part 5: Parse and Display a Live Hacker News Page
```ruby
require 'nokogiri'
require 'open-uri'

html_file = open('https://news.ycombinator.com/item?id=20039589')
nokogiri_document = Nokogiri.parse(html_file)
```
*Figure 9*.  Opening a webpage and passing the contents to Nokogiri.

Let's parse some live Hacker News pages.  We'll first modify our `runner.rb` file so that we can easily retrieve the contents of a webpage.  In Figure 9, we require Ruby's [`OpenURI`][Open URI] module.  This allows us to capture the HTML from a URL using the `#open` method, which returns an object that the `Nokogiri.parse` method accepts, just as it accepted the string objects we've been passing to it.  Let's require the `OpenURI` module in `runner.rb`.

```
$ ruby driver.rb https://news.ycombinator.com/item?id=10059249

Oxford University Machine Learning Course (Hacker News ID: 10059249)
    URL: https://www.cs.ox.ac.uk/people/nando.defreitas/machinelearning
    Author: jcr
    Points: 63

    Comments:
    "What's the barrier to entry like for this? ..."
    - spike021

    "Machine Learning is a mathematical discipline, and  ..."
    - hlfw0rd

    continued ...
```
*Figure 10*.  Parsing a live webpage by passing the URL as a command line argument.



### Part 6: Enable ARGV command line arguments

We'll also update our `driver.rb` file to work with command line arguments (ARGV).  When we execute `driver.rb`, we should be able to pass the URL of a Hacker News comment thread, and that post and its comments should be printed on the command line (see Figure 10).

If you are not familiar with ARGV, this would be the time to do exercise_67_mini for an idea of what it is.


## Conclusion
There are a lot of pieces to this exercise, so let's think about what we've done.  We've taken information encoded in HTML on Hacker News and converted it into a format readable on the command line.  Essentially, we have a simple Hacker News command line reader.

In order to present the information on the command line, we had to first create Ruby objects to represent the post and comments on a Hacker News page.  Representing the post and objects in our own objects gave us control over their behaviors, and allowed us to manipulate them as we needed.  We'll be continuing this pattern of loading data into Ruby objects that we can use.

In addition, we were able to practice using Nokogiri further than we did in the previous exercise.


[BBR Guide]: http://ruby.bastardsbook.com/chapters/html-parsing/
[CSS selectors]: https://developer.mozilla.org/en-US/docs/Web/Guide/CSS/Getting_started/Selectors
[Hacker News]: http://news.ycombinator.com
[HN Comment Thread]: https://news.ycombinator.com/item?id=20039589
[Nokogiri]: https://github.com/sparklemotion/nokogiri
[Nokogiri installation]: http://www.nokogiri.org/tutorials/installing_nokogiri.html
[Open URI]: http://www.ruby-doc.org/stdlib-2.6.3/libdoc/open-uri/rdoc/OpenURI.html
[web scraping]: https://en.wikipedia.org/wiki/Web_scraping
