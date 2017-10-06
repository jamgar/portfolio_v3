---
title: Workout Tracker app with Sinatra and Ruby
tags: 'ruby, sinatra'
date: 2017-07-06T11:19:30.940Z
image: null
directory_index: false
---
In this section of the Learn.co curriculum we covered Sinatra. [Sinatra](http://www.sinatrarb.com/) is a Domain Specific Language (DSL) framework for creating web applications in Ruby quickly. With Sinatra you can create a simple static website or a full fledged web application. At the end of the Learn.co Sinatra section I was tasked with building a web application with the following specification:
Specs:

* Use Sinatra to build the app
* Use ActiveRecord for storing information in a database
* Include more than one model class (list of model class names e.g. User, Post, Category)
* Include at least one has_many relationship (x has_many y e.g. User has_many Posts)
* Include user accounts
* Ensure that users can't modify content created by other users
* Include user input validations
* Display validation failures to user with error message (example form URL e.g. /posts/new)

The actual application was up to me to decide as long as I met the specifications and did not do a Twitter clone or blog. They were heavily used as labs or examples for the Sinatra sections. I decided on a Workout Tracker App, since working out is something I enjoy doing.

###The Basics
For a very basic Sinatra app you can install sinatra gem, create a main.rb file add a route:

```ruby
# main.rb
require 'sinatra'

get '/' do
  'Hello World'
end
```
Open your terminal and run the following command in the directory that the main.rb is in:

```bash
~$ ruby main.rb
== Sinatra (v2.0.0) has taken the stage on 4567 for development with backup from Thin
Thin web server (v1.7.1 codename Muffin Mode)
Maximum connections set to 1024
Listening on localhost:4567, CTRL+C to stop
```
Open your web browser to localhost:4567(or whatever port it is listen) and there you go.

### Project Set Up

This project was going to be more involved than a basic Sinatra app, which meant that it required more setup or boilerplate to be created before we could start running the app. To start out I created my /workout-tracker folder and inside that directory I ran `bundle init`, which created a Gemfile. I knew the gems I would be using so I placed them all in the Gemfile. Here are the gems:

```ruby
# Gemfile
source "https://rubygems.org"

gem 'sinatra'
gem 'activerecord', :require => 'active_record'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
gem 'rake'
gem 'require_all'
gem 'sqlite3'
gem 'thin'
gem 'shotgun'
gem 'pry'
gem 'bcrypt'
gem "tux"
gem 'rack-flash3'

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test'
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git'
end

```

The next file I created was config.ru, which is used in Rack-based apps such as Sinatra and Rails, as an entry point for the app when it starts up.

```ruby
# config.ru
require './config/environment'
...
use Rack::MethodOverride
# ... other controllers in your application go here and are preceded with 'use'
run ApplicationController
```

I required my environment file, which I discuss later, and then different files to 'use' or 'run'. You can have many 'use' files, but only one 'run' file declared. The file that is preceded with 'run' is the main file of the application. In this case it will be my ApplicationController.

After that I create a Rakefile.

```ruby
# Rakefile
require_relative './config/environment'
require 'sinatra/activerecord/rake'

# My task
task :console do
  Pry.start
end
```

This gives me access to rake task, and also allows me to create my own task, which I did `task :console`. This task allows me go into a `pry` console to work with my models.

You may have noticed I require config/environment file in my other files. This is the file that has my environment configurations.

```ruby
# environment.rb
ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/#{ENV['SINATRA_ENV']}.sqlite"
)

require_all 'app'
```

This is also were I make my connection between ActiveRecord and the database. In this case I used sqlite3 for my database. The other line I want to point out is `require_all` this is a gem that allows you to require all files in a directory instead of having to require each file individually. So I am requiring all files in the 'app' folder.

The app folder is where the controllers, models, and views will be stored. Speaking of controllers, after creating the /app/controllers directory I created my application_controller.rb file. This is the file that is referred to in the config.ru file `run ApplicationController`.

```ruby
# application_controller.rb
require './config/environment'
require 'rack-flash'

class ApplicationController < Sinatra::Base
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "workout_secret"
    use Rack::Flash
  end

  get '/' do
    erb :index
  end
end
```

In this file I used the `configure do` block to set some configurations I will need throughout my application. The `set :views, 'app/views'` tells Sinatra to use the 'app/views directory for the views file instead of the default location, which is a views folder in the root directory of the application. I will be using sessions to store the current user and checking if a user is logged in. `set: :session_secret, "workout_secret"` is an encryption key used to create session_id. Then `use Rack::Flash` is there to be able to user flash messages. Lastly we have our root route so when a user goes to the Workout Trackers website it will initially hit the root route '/' and will be presented with the index page which is stored in the root views directory.

Then next two files I created where `layout.erb` and `index.erb` in the app/views folder.

```ruby
# layout.erb
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Workout Tracker App</title>
  <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
</head>
<body>
<%= yield %>
</body>
</html>
```

```ruby
# index.erb
<h1>Welcome to Workout Tracker</h1>
```

The main things I want to point out is the `<%= yield %>` and `<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">`. The `<%= yield %>` identifies where the content of the other views will be displayed. The next thing is I am using w3schools css framework. This was actually one of the last steps implemented after I finished the applications. I initially developed it without any css because I wanted to focus on the functionality of the application. It was only after I finished that part did I go back and add css. I had never used w3css, but was wanting to and this project presented the opportunity.

With all of this boilerplate set up I could go into my terminal and run `shotgun`. Then go to localhost:9393 and be present with the Welcome message.

### Writing Test

My secondary objective during this project was to dive into writing my own test. Most, if not all, of the labs in Learn.co use Test Driven Development (TDD) to guide you through the completion of the labs, and these test are already written for me. I wanted to learn how to write these test myself because I know it is a skill that I will need and I knew this project was small enough to get some experience. So I went into writing test for this project, and I really enjoyed the challenge of learning something new. Since this was basically my first time writing test I relied heavily on lab examples and google. The approach I took was to write some test for a model, controller, or feature, run the tests and then write the code to pass the tests. I continued that cycle until I completed the project. The testing tools I used were RSpec and Capybara. I will not go into much detail about the test, but I started out with writing test for the models. Next I wrote tests for the controllers and then a features.

### Tables and Models

I wanted to allow users to signup and login so I first created a Users table and model.

```ruby
class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password_digest
    end
  end
end
```

During signup I would only require a 'username', 'email, and 'password'. The reason there is a 'password_digest' field, instead of just 'password', is because that is what the bcrypt gem uses to store the encrypted password. Every other place in the application password is used and bcrypt will handle the rest.

The User model was straightforward.

```ruby
# user.rb
class User < ActiveRecord::Base
  has_secure_password
  has_many :workouts
  validates_presence_of :username, :email
end
```

The `has_secure_password` is a bcrypt method used to had the encryption and decryption of the password. Since a user will most like enter more than one workout I created the one-to-many association `has_many :workouts`. Lastly is the validations for username and email. A user has to enter the two fields and password, of course, during signup.

The next table and model I created was for Workouts.

```ruby
class CreateWorkouts < ActiveRecord::Migration[5.1]
  def change
    create_table :workouts do |t|
      t.string :title
      t.string :date
      t.integer :duration
      t.text :note
      t.integer :user_id
      t.timestamps
    end
  end
end
```

Everything here is pretty straight forward. I included the `:user_id` field for the one-to-many association. The other field is the `t.timestamp`, which will create the `:created_at` and `:updated_at` fields for me in my table. They are not necessary, but nice to have just in case I wanted to use these dates.

```ruby
# workout.rb
class Workout < ActiveRecord::Base
  belongs_to :user
  has_many :workout_exercises
  has_many :exercises, through: :workout_exercises
  validates_presence_of :title, :date
end
```

The next few models are more involved. I start with adding the association `belongs_to :user` for the one-to-many. The next two lines are used for the many-to-many association. Basically, workouts can be associated with many exercises and vice versa. To make these associations to work I have to create a 'join' table, which is the workout_exercises. Workout has an one-to-many association to workout_exercises table, and has a many-to-many association to exercise 'through' workout_exercises. Then the validations for `:title` and `date`.

Exercise was the next table and model.

```ruby
class CreateExercises < ActiveRecord::Migration[5.1]
  def change
    create_table :exercises do |t|
      t.string :name
    end
  end
end
```

I just created the exercises table and stored the exercise name.

```ruby
# exercise.rb
class Exercise < ActiveRecord::Base
  has_many :workout_exercises
  has_many :workouts, through: :workout_exercises
end
```

Again, I am adding the one-to-many association to workout_exercises, and the many-to-many to workouts 'through' workout_exercises.

The final table and model was the 'join' table, workout_exercises.

```ruby
class CreateWorkoutExercise < ActiveRecord::Migration[5.1]
  def change
    create_table :workout_exercises do |t|
      t.integer :workout_id
      t.integer :exercise_id
    end
  end
end
```

I am creating the table to store workout_id and exercise_id, which will track the many-to-many associations for workouts and exercises.

```ruby
class WorkoutExercise < ActiveRecord::Base
  belongs_to :workout
  belongs_to :exercise
end
```

These `belong_to` create part of the one-to-many association for the join table. If you want to learn more about ActiveRecord associations you can get some information [here](http://guides.rubyonrails.org/association_basics.html).

### Controllers

I will only cover the WorkoutsController to keep this article from being too long.

```ruby
class WorkoutsController < ApplicationController

  get '/workouts' do
    if logged_in?
      @workouts = Workout.where(user_id: session[:user_id])
      erb :'/workouts/index'
    else
      redirect to '/login'
    end
  end

  get '/workouts/new' do
    if logged_in?
      erb :'/workouts/new'
    else
      redirect to '/login'
    end
  end
  ...
end
```

The first route is the workouts index route, which first checks if a user is logged in and then only display the users workouts that they created. Next is a route for displaying the new workout form.

```ruby
  ...
  post '/workouts' do
    @workout = Workout.create(title: params[:title],
                              date: params[:date],
                              duration: params[:duration],
                              note: params[:note],
                              user_id: session[:user_id])

    @workout.exercise_ids = params[:exercises]
    if !params[:exercise].empty?
      @workout.exercises << Exercise.create(name: params[:exercise])
    end
    @workout.save

    flash[:message] = "Workout was successfully created."

    redirect to "/workouts/#{@workout.id}"
  end

  get '/workouts/:id' do
    @workout = Workout.find_by(id: params[:id])
    erb :'/workouts/show'
    if logged_in?
      @workout = Workout.find_by(id: params[:id])
      erb :'/workouts/show'
    else
      redirect to '/login'
    end
  end
  ...
```
This is a 'post' route, which when the new workout form is submitted it will go this part of the controller to create the new workout. As you can see it will also allow a user to enter a new exercise to create and associate with the workout, and redirect them the to the show page of that workout, which is the next route `get '/workouts/:id' do`. It will find the workout based on the id passed in through the params.

```ruby
  get '/workouts/:id/edit' do
    if logged_in?
      @workout = Workout.find_by(id: params[:id])
      erb :'/workouts/edit'
    else
      redirect to '/login'
    end
  end

  patch '/workouts/:id' do
    @workout = Workout.find_by(id: params[:id])
    @workout.update(title: params[:title],
                    date: params[:date],
                    duration: params[:duration],
                    note: params[:note])
                    
    @workout.exercise_ids = params[:exercises]
    if !params[:exercise].empty?
      @workout.exercises << Exercise.create(name: params[:exercise])
    end
    @workout.save

    flash[:message] = "Successfully updated workout."
    redirect to "/workouts/#{@workout.id}"    
  end
```
The next two routes are for editing. The first is for displaying the edit form with the current values. The second is the patch route which is called when the edit form is submitted. This will send the updated information to the model to update the record.

### Views

The only thing I will cover in the views is the workout edit form because it shows a unique situation.

```ruby
# edit.erb
<header class="w3-container w3-teal">
  <h1>Edit Workout</h1>
</header>

<div class="w3-container w3-half w3-margin-top">
<form class="w3-container w3-card-4" action="/workouts/<%= @workout.id %>" method="POST">
  <input name="_method" type="hidden" value="patch">
  <p>
    <label for="title">Title:</label>
    <input class="w3-input" type="text" name="title" value="<%= @workout.title %>" />
  </p>
  <p>
    <label for="date">Date:</label>
    <input class="w3-input" type="text" name="date" value="<%= @workout.date %>" />
  </p>
  ...
</form>
</div>
```

As you can see, it is basically HTML with some ruby in the <%= %> tags. The interesting part is the `<input name="_method" type="hidden" value="patch">` field inside the form. HTML in Sinatra basically only knows how to handle GET and POST methods in a form. So a hack to get the form to submit a PUT, PATCH, or DELETE is to create a hidden input field inside the form tags. You will also need to include the `use Rack::MethodOverride` in the config.ru file. I found that it needs to be declared before the other 'use' files or at least before any controller that is going to be using PUT, PATCH, or DELETE.

That is my Workout Tracker App. I was not fancy, but I learned from it, and that is what is most important. If you are learning Ruby and/or Rails then I would suggest learning Sinatra. It will give you a different tool to work with Ruby, and it is fun.

Peace, Love, and Happy coding!
