---
title: The Gist of ORM
tags: ruby
date: 2017-09-15T11:09:57.644Z
image: null
directory_index: false
---
###ORM = Object Relational Mapping

This article is a simple overview of what is ORM using Ruby and Sqlite3. I will give some code examples to better help explain the concept. ORM is a coding pattern used for a program to communicate with the database in a organized fashion. It is commonly used with Object Oriented Programming languages. The idea is that for each table in a database there is a corresponding class in the program and for each row in that table there is a corresponding instance of the class. So, if there is a database called 'marathons' and it has a table with 'races' there will be a class called 'race' and if the table has 10 rows (or records) than there will be 10 instances created in memory. As a side note, the convention for naming tables and classes in the ruby ORM world is to name the table as the pluralized version for the class name. That is why in our example the table will be called "races" and the class 'race'.

![orm mapping](/images/uploads/orm1.png)

In our Ruby program we will continue with the marathon theme since I enjoy running. The first step is to create a connection to the database. I will create this connection in an environment.rb file.

```ruby
# Save the connection to a global variable
DB = {:conn => SQLite3::Database.new("db/marathons.db")}

```
Now that we have the initial setup done we can move on to the class. The idea here is that we will create a class called 'race' and then add some attributes (a.k.a. properties) and methods. 

```ruby
class Race
  attr_accessor  :name, :date
  attr_reader :id
  
  def initialize(name:, date:, id: nil)
    @name = name
    @date = date
    @id = id
  end

  def self.create_table
     sql = <<-SQL
      CREATE TABLE IF NOT EXISTS marathons (
      id INTEGER PRIMARY KEY,
      name TEXT,
      date TEXT
    SQL

    DB[:conn].execute(sql)
  end
end
```
We start off with defining our call attributes. The `attr_accessor` is a shorthand for writing our getters and setters. The equivalent in longhand would be as:

```ruby
  # Setter 
  def name=(name)
    @name = name
  end
  
  # Getter
  def name
    @name
  end
```
This can get very repetitive and is not fun, and ruby was created to be fun. Moving on... Another shorthand you see is `attr_reader` which is the same as the Getter, and as you might have guessed it there is also an `attr_writer` which is the same as the Setter. The `attr_reader` will only allow code from outside of the class to be able to read the 'id' in this case. The only way to set the 'id' is from within the class.

Next is the `initialize`, which takes in parameters and 'id' being defaulted to 'nil'. The reason for 'id' defaulting to 'nil' is because we want to populate it with the unique 'id' that the Sqlite3 engine will create. This way no two class instances will be populated with the same 'id'. So 'id' will stay 'nil' until we populate it in the 'save' method, which we have not created yet. For now we will just populate the 'name', and 'date' attributes.

The `self.create_table` is a class method that will handle the creation of the 'races' table if it does not exist. This method will most likely be called from an external file at startup. Side note, if you are not familiar with the syntax `<<-SQL ... SQL` it is called heredoc. Basically it helps you write a long string of text on multiple line, but still have your code be processed as a single line of text. It is used to make your code look nicer and more readable.

```ruby
class Race
  ...

  def self.drop_table
    sql = "DROP TABLE IF EXISTS races"
    DB[:conn].execute(sql)
  end  

  def self.all
    sql = "SELECT * FROM races"
    rows = DB[:conn].execute(sql)
    
    rows.collect do |row|
      self.new_from_db(row)
    end
  end

  def self.new_from_db(row)
    self.new.tap do |race|
      race.id = row[0]
      race.name = row[1]
      race.date = row[2
    end
  end
end
```
This `self.drop_table` class method will delete the 'races' table, if it exists. The next class method is `self.all`, which will return an array of 'race' instances for each row in the 'races' table. The `self.new_from_db` is a class helper method that will create and return a new class instance based off the 'row' parameter that is passed in.

```ruby
class Race
  ...

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO races (name, date)
        VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.date)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM races").flatten.first
    end
  end

  def update
    sql = <<-SQL
      UPDATE races SET name = ?, date = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.date, self.id)
  end
end
```

The `save` and `update` are instance methods that only apply to an instance of a class. The `save` method will check to see if the current instance has an 'id' and if it does then it knows that this is an existing row in the database and will use the `update` method to make the change to the row in the database. It also helps to not create duplicate rows. If `self.id` returns false then it knows this is a new row to be inserted into the database. Once the row has been created in the database the `save` method will query for the new row 'id', which is the last row inserted and populates the `@id` attribute. The `update` method, as explained earlier, is called if the row has already been created and then will update the values in the database with the new values.

```ruby
class Race
  ...
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM races
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM races
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.sort_by_name(order = "ASC")
    sql = <<-SQL
      SELECT *
      FROM races
      ORDER BY name ?
    SQL

    rows = DB[:conn].execute(sql, order)
    self.new_from_rows(rows)
  end

  def self.new_from_rows(rows)
    rows.collect do |row|
      self.new_from_db(row)
    end
  end
end
```

The `find_by_id` and `find_by_name` are class methods that finds the first row based on the column and value passed in and returns the 'race' instance. `self.sort_by_name` is another class method that sorts the rows by name in ascending or descending order and returns an ordered array of 'race' instances by using the `self.new_from_rows` class method.

From this small example you can see that there is alot that goes into building an ORM, and thankfully there is a ruby gem called ActiveRecord that takes care of all this for us and so much more. As my example is pretty specific for the my program ActiveRecord has abstracted most of what my code does to Class and Instance modules. If you were to look at a model in a Ruby on Rails app, which uses ActiveRecord, you would see:

```ruby
class Race < ActiveRecord::Base
end
```
The class would be empty! Not really, the inheritance from [ActiveRecord](https://rubygems.org/gems/activerecord/versions/5.0.0.1) comes with a ton code that we get for free. Got to love free, and thank you DHH and all of the contributers for their great work. My mission was to give you the gist of how an ORM works, which I hope I fulfilled. I believe having a basic understand for this will make me a better programmer and gives me a better appreciation for the work that has been put into ActiveRecord and you as well.

Peace, Love, and Happy coding!
