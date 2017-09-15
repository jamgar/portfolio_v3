---
title: Building a Data Cli Gem
tags: 'ruby, gem'
date: 2017-05-19T23:46:17.711Z
image: null
directory_index: false
---
This is a project that is part of the curriculum for [Flatiron School](https://flatironschool.com/). The basic Idea is to build a gem that will scrape a website and return data based on the users input. Some of the requirements are as followed:

**Requirements**

1. Provide a CLI

2. CLI must provide access to data from a web page.

3. The data provided must go at least one level deep, generally by showing the user a list of available data and then being able to drill down

into a specific item.

4. The CLI application can not be a Music CLI application as that is too similiar to the other OO Ruby final project. Also please refrain from

using Kickstarter as that was used for the scraping 'code along'. Look at the example domains below for inspiration.

5. Use good OO design patterns. You should be creating a collection of objects - not hashes.

6. For bonus points publish the gem to RubyGems.

**What should I build?**

I was not sure at first, but the lesson provides a couple of example projects like a now-playing which returns movies playing now. The other was worlds best restaurants, that you might guess, returns the 50 top best restaurants. I decided on concert-finder-cli-app, which would list out concerts based some users input. I did a simple google search for 'concerts' and the top listings were [Songkick](https://www.songkick.com), Tickmaster, and Vividseats to name a few. I looked at all of these and decided on Songkick to retrieve my information.

**How to build it?**

Now that I knew what I was going to build, I needed to figure out how to build a gem. Up to this point in the curriculum I had built a cli game so I knew about working with the cli and writing classes, but I have never built a gem. I had been curious on how they are built so I knew it would be fun. The lesson gave resources for further research such as RubyGems' own documentation on how to build a gem and how to publish a gem. Who would have thought to look there? :)) (Not me, but now I know) This is not surprising since the Open Source community is so awesome about sharing knowledge and spreading the love. Other resources where videos created for Learn.co students (The learning platform for Flatiron School). One of the key things I found in these resources was [Bundler](https://bundler.io/v1.14/bundle_gem.html) has a command `bundle gem <GEM_NAME> [OPTIONS]` that generates the gem skeleton of files and folders. Score! I looked over the generated files because I wanted to know how it worked. Also I had a feeling that I would have to make changes, which I did.  Below is the example of the Bundle Gem skeleton:

```

|-- bin

    |-- console
    
    |-- setup

|-- lib

    |-- concert_finder_cli_app
    
        |-- version.rb
    
    |-- concert_finder_cli_app.rb

|-- spec

    |-- concert_finder_cli_app_spec.rb
    
    |-- spec_helper.rb

|-- .gitignore

|-- .rspec NOTE: you get the option upon generation to use rspec or minitest

|-- .travis.yml

|-- CODE_OF_CONDUCT.MD

|-- concert_finder_cli_app.gemspec

|-- Gemfile

|-- LICENSE.txt

|-- Rakefile

|-- README.md

```

As you can see this boilerplate is a great starting point for someone who in the learning phase of Ruby.

**Building**

The example provided by the lesson were a great resource to helping me to determine if I was on the right track so I kept referring back to them. The main thing was to decide what class and methods I would need. The first thing I did was to create a config folder at the root of the directory so I could create an environment file, which would allow me to require gems and files I would need to use throughout the program.

My first class I needed was a `Scraper` class to help me get the html content from the web page to be parsed. I used Nokogiri and Open-URL to help accomplish getting the html. I created the class method` #get_cities` that would return a list of `City` classes from the html. Next I created the class method `#get_concerts(city)` that would return a list of `Concert` classes based on the parameter `city`.

I created the `City` class that initializes with a `name` and `url`. It stores these parameter is their respective instant variables and also add the new instance to a class variable called `@@all`

I then created the `Concert` class that initializes with `artist`, `date`, and `location`. It stores these parameter is their respective instant variables and also add the new instance to a class variable called `@@all`

Now that I had the "Backend" laid out I began working on the cli part. This would be part of the gem that would interact with the user. I created a `CLI` class. The first method was `#call`, which starts the interaction. `#call` welcomes the user with "Welcome to Concert Finder!" and ask them to "Choose a city to view upcoming concerts:". Next it calls the `#print_cities` what for a input and then call `#print_concerts(input.to_i)`.

I created the `#print_cities` method inside of the `CLI` class. This method calls the `Scraper.get_cities` method and then print out the cities.

Next I created the `#print_concerts(index)` method inside of `CLI` class. This method calls the `Scraper.get_cities` to get the list of cities. Then calls the `Scraper.get_concerts(cities[index-1])` and uses the cities returned to pass in the city to look up. Then will print out each concert with Date:, Artist:, and Location:

**To be continued**

As you can see the program does not do much, but what I learned from it was great. This lab was super fun and challenging. I had to think on my own on how to structure the classes and methods and apply what I have learned from the previous lessons. I did not do the bonus, which is to actually publish it. I would like to refactor and possibly add some features before taking that next step.

Peace, Love, and Happy coding!
