---
layout: post
title: "Generating Test Data for Rails Projects"
description: "Discusses the development of a script for populating a new Rails database with test data."
category: Post
tags: [Database, Rails, Ruby]
image:
  feature: layout-posts.jpg
comments: false
---

How often have you created a database for a new Rails application and then sat staring at the empty tables? Often times when building a new application you need sample data to help flesh out the user interface or to show off the application to your customer. Rails provides a convenient method of loading this data via the *seeds.rb* file, but you still have to create the content for this file. This article will discuss a mostly automated way of generating content for your database.

<!-- more -->

But wait you say, this problem isn't new; there must be existing tools to do this. That is true. You can certainly use an existing and tested tool if you are under a time crunch (see the list below). But, if you have the time, you can create a tool that you will be familiar with and probably learn more about Ruby and Rails in the process. Sometimes the journey is worth more than the destination.

> ### Alternative Sample Data Generators
> - [Faker](https://github.com/stympy/faker) - a port of Data::Faker from Perl to generate fake data
> - [FFaker](https://github.com/ffaker/ffaker) - a diverged fork of Faker
> - [Forgery](https://github.com/sevenwire/forgery) - a customizable generator
> - [Randexp](https://github.com/benburkert/randexp) - generate data based on a regular expression template
> - [Mockaroo](http://www.mockaroo.com) - an online service to generate small files of sample data

## Getting Started

So let's get started. First we are going to need a Rails application to work with. I think a basic ecommerce-like site would give us a relatively common set of subject tables to work with. For the purposes of this article though, we are only going to look at the *customers* table. Using the rails command line program we create the *buyit* site. 

```
$ rails new buyit
      create  
      create  README.rdoc
      create  Rakefile
      create  config.ru
      create  .gitignore
      create  Gemfile
      create  app
      create  app/assets/javascripts/application.js
...
Using web-console 2.3.0
Bundle complete! 12 Gemfile dependencies, 54 gems now installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.
         run  bundle exec spring binstub --all
* bin/rake: spring inserted
* bin/rails: spring inserted
```

All right, let's generate a model for our data. Since we are not going to focus on the user interface aspect of this application, we will generate scaffolding rather than just the model alone. When we populate our database with test data, we can immediate see how it looks through the application.

```
$ cd buyit
$ rails generate scaffold customer firstName:string lastName:string birthDate:datetime \
streetAddress1:string city:string state:string \
zipCode:string phoneNumber:string email:string
Running via Spring preloader in process 798
      invoke  active_record
      create    db/migrate/20160307135044_create_customers.rb
      create    app/models/customer.rb
      invoke    test_unit
      create      test/models/customer_test.rb
      create      test/fixtures/customers.yml
...
      create      app/assets/stylesheets/customers.scss
      invoke  scss
      create    app/assets/stylesheets/scaffolds.scss
$ rails db:migrate
== 20160307135044 CreateCustomers: migrating ==================================
-- create_table(:customers)
   -> 0.0023s
== 20160307135044 CreateCustomers: migrated (0.0024s) =========================
```

> The default database of a new Rails application uses SQLite, so the migrate command will create the database if it doesn't already exist. If we were using MySQL/MariaDB or PostgreSQL then we would have needed to precede the migration with a *rake db:create* first.

The last step of the previous commands pushed our changes into the database. If we were to visualize what has been created it would look something like the image below.

![Database Diagram](/images/posts/generating-test-data-for-rails-projects-01.png)

We are now going to build our script to generate test data via an iterative process. Each step will bring us one step closer to the finished project.

## Listing Tables

The first step that we need to accomplish is to connect to the database and get a list of tables. Since a database may contain many tables for which we do not want to generate test data for, this first step allows us to pare down the list to those ones we want.

> Since this is a Rails application we can take advantage of using ActiveRecord to do a lot of the database work for us. In fact, we can use ActiveRecord outside of the Rails application yet take advantage of the database configuration file (config/database.yml)

In the code below, we establish a connection to the development database in our Rails application. We then use that connection to populate a hash table with the names of the tables in the database. At the same time, we are adding some additional tracking fields that the script will need.

```ruby
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3'
  :host => nil,
  :database => 'db/development.sqlite3',
  :username => nil,
  :password => nil,
  :sslca => nil,       # Used for a secure connection
  :sslcert => nil,     # ...
  :sslkey => nil       # ...
)

tables = {}
ActiveRecord::Base.connection.tables.each do |table_name|
  tables[table_name] = { 
    :records_to_load => 0,          # load table with test data if > 0
  :truncate_before_load => false  # delete all records before loading table?
  }
end
```

## Configuration Management

As we are building this program we are going to have the need to track different kinds of configuration information. This configuration information is going to need to be readable by both ourselves and our program. The easiest way to save and load our configuration files is to use Ruby's built-in ability to save and load objects using [YAML](http://yaml.org).

```ruby
# To save *contents* to "tables.yml" file
File.open("tables.yml", "w") { 
  |file| file.write(YAML.dump(contents))
}

# To load *contents* from "tables.yml" file
contents = YAML.load(File.read("tables.yml"))
```

The list of tables our program generates will be stored in the *tables.yml* file. A file generated from our sample Rails program is shown below. I have gone ahead and annotated the file to indicate that we want to generate 10 test records and also empty the table before loading.

```yaml
---
schema_migrations:
  :records_to_load: 0           # ignore this table
  :truncate_before_load: false
customers:
  :records_to_load: 10          # generate 10 records
  :truncate_before_load: true   # empty table before load
```

## Retrieving Column Information

Now we need to generate a list of columns and their attributes for the *customers* table in this example. We need to understand which fields are automatically handled by the database, which ones might be unique, the data type of the columns, and any limitations such as length or nullability.

Similar to the way that we got a table list, we can iterate over our tables and ask ActiveRecord to return information about the columns in those tables. Also like the previous table list, we will be adding additional attributes for our purposes. Specifically that would be the *generator* property.

```ruby
columns = {}
ActiveRecord::Base.connection.columns(table_name).each do |column|
  columns[column.name] = {
  :precision => column.precision,
  :scale => column.scale,
  :limit => column.limit,
  :sql_type => column.sql_type,
  :null => column.null,
  :default => column.default,
  :generator => "ignore_generator"   # added to assign data generator
  }
end
```

This process will create one YAML formatted file per table with the name of the table. In this case, that would mean *customers.yml*. Only the first two columns *id* and *firstName* have been shown below.

```yaml
---
id:
  :precision: 
  :scale: 
  :limit: 
  :sql_type: INTEGER
  :null: false
  :default: 
  :generator: ignore_generator
firstName:
  :precision: 
  :scale: 
  :limit: 
  :sql_type: varchar
  :null: true
  :default: 
  :generator: ignore_generator
# ... rest of file omitted for brevity
```

## Basic Generator

At this stage, we have a list of columns that we would like to populate but currently have no means of populating them. Looks like we are going to need some generators. For this first pass, let's create a really basic string generator. While the data won't look that great, it will allow us to progress to the next steps of creating and then loading that data.

```ruby
module Generator
  
  class StringGenerator 
  
  # optionally specifying a seed helps to add repeatability
  # to our random number generation
    def initialize(seed=nil)
      seed = Random.new_seed if seed.nil?
      @prng = Random.new(seed)
    end

  # pick a random, mixed-case, alphabetic string of 
  # the specified length
    def value(length=1)
      list = [('a'..'z').to_a, ('A'..'Z').to_a].flatten
      
    result = ""
    length.times do 
      result << list[@prng.rand(list.length)]
      end
    result
    end
    
  end
    
end
```
Now that we have a basic generator, we need to associate it with the database columns that we want to use it for. We do this by modifying the value of the *generator* property in our *customers.yml* file. Again, only the first two columns are being shown. 

```yaml
---
id:
  :precision: 
  :scale: 
  :limit: 
  :sql_type: INTEGER
  :null: false
  :default: 
  :generator: ignore_generator
firstName:
  :precision: 
  :scale: 
  :limit: 
  :sql_type: varchar
  :null: true
  :default: 
  :generator: Generator::StringGenerator.new.value(8)
# ... rest of file omitted for brevity
```

> I have chosen a random string of 8 characters to be generated for the first name column.

Now that we can generate data, we should try to load it into our database table. 

## Loading the Database

To load a new record into the database, we need to pull all of our previous work together and use ActiveRecord once again. Sample code to do this follows, but first let's discuss the actual steps that we need to perform.

1. Locate and bring all of the ActiveRecord models from our Rails project into our namespace
2. Produce a list of tables that have a *records\_to\_load* property greater than zero
3. Loop through these tables one at a time
4.   For each table, locate the ActiveRecord model associated with it
5.   Produce a list of columns for that table that have an associated generator
6.   Loop through the number of records that we want to load into the table
7.     Initialize a new record template from the current ActiveRecord table model
8.     Loop through each column
9.       Generate test data by evaluating the *generator* code and assign it to the current column
10.    After all columns have been processed, then save the record to the database
11.  Generate the next test record
12. Process the next table in the list 

```ruby
# load models from Rails project
models = {}
Dir[rails_model_path + "/*.rb"].each do |model_file|
  require model_file
  basename  = File.basename(model_file, File.extname(model_file))
  models[basename.camelize] = { :klass => basename.camelize.constantize }
end

# loop through tables to load (assume already filtered)
tables.each do |table, options|

  # identify model associated with this table
  model = models.detect { 
    |model, options| options[:klass].table_name == table
  }[1][:klass]

  # find all columns that have a generator
  columns = columns.reject { 
    |column, options| options[:generator] == "ignore_generator"
  }

  # loop through number of records to load
  options[:records_to_load].times do
      # initialize a new ActiveRecord for the current table
      record = model.new

      # loop through each column that has an assigned generator
      columns.each do |column, options|
        generator = options[:generator]
      record[column] = eval(generator)  # generate test data here
      end

      # save record to the database
      record.save
   end    
end
```

## Checking Our Progress

At this point, we have selected a table to load, retrieved its column data, assigned a string generator to each column, and stored the data back in the database. Now would be a good time to see that data through the Rails interface.

![Image of Not Pretty Load](/images/posts/generating-test-data-for-rails-projects-02.png)

## Improving Our Results

Well, it's functional but not pretty. If we use our domain knowledge to apply some heuristics to the generators then we can generate more reasonable looking data. Focusing on the fields related to the customer's name; if instead of generating random looking strings, we selected from a list of common names that would be a step in the right direction.

The name generator below uses separate lists of names based on gender. When the generator is created it randomly chooses a gender and makes name choices based on it.

```ruby
module Generator

  class NameGenerator

  def initialize(seed=nil, gender=nil, culture='en-us')
      seed = Random.new_seed if seed.nil?
      @prng = Random.new(seed)

      @first_names_male = ['John', 'Matthew', 'Martin']
      @middle_names_male = ['Charles', 'Michael', 'William']
      @first_names_female = ['Emma', 'Mia', 'Harper']
      @middle_names_female = ['Elizabeth', 'Marie', 'Beverly']
      @last_names = ['Clark', 'Smith', 'Johnson']s
      @suffix_male = ['Jr', 'Sr', 'I']
      
    @gender = ["m","f"].shuffle[0] if gender == nil
    end
    
    def first_name()
    if @gender == 'm'
      @first_names_male[@prng.rand(@first_names_male.length)]
      else
        @first_names_female[@prng.rand(@first_names_female.length)]
      end
  end
  
    # ... rest of class not shown 

  end 

end
```

Let's reload the table and see how it looks now. The image below shows more realistic looking data.

![Image of Not Pretty Load](/images/posts/generating-test-data-for-rails-projects-03.png)

## Tidying Things Up

That looks good and accomplishes what we need, but can we refine it a little further? What if, we moved the hard-coded lists to an external file and stored it in a folder using a localization code. We would then have the ability to customize the list without altering the tool as well as supporting data in multiple languages.

![Image of External Data Files](/images/posts/generating-test-data-for-rails-projects-04.png)

> In the image above we can see several different data files that contain American-English (i.e. en-us) data in them.

## Better Generators

If we look closely at the output data, while it looks reasonable, there is still a subtle issue going on. Since the generators do not maintain state, subsequent calls return unrelated data. For instance, we have a data file that contains U.S. states and their capitals. When we are loading records, we make separate calls to get the city and state values. This means that the random selection most likely selected different rows for each value. This results, in our example, with a row where Little Rock, the capital of Arkansas, is incorrectly paired with the state of Idaho. This can also result in the pairing of a male first name with a female middle name when handling demographics fields.

![Image of City Mismatch](/images/posts/generating-test-data-for-rails-projects-05.png))

> The image above highlights the incorrect pairings of cities and states that can occur with our current implementation.

In the code for a modified generator for the address fields shown below, we can see several improvements. First we are now loading our data from a external file with an optional culture code. Secondly, there is a consistent method named *generate* which sets the state of the generator. This will provide a consistent set of multiple values until it is *re-generated* again. Finally, we access the generated values via read-only properties such as *city*.

```ruby
module Generator

  class AddressGenerator

    attr_reader :city

    def initialize(seed=nil, culture='en-us')
      seed = Random.new_seed if seed.nil?

      @prng = Random.new(seed)
    
      data_dir = File.dirname(__FILE__) + "/data/#{culture}/"
      
      @states = CSV.readlines("#{data_dir}us_states_and_capitals.csv")
    end

    def generate
      state_record = sample(@states)

      @city = state_record[2]
      @state_name  = state_record[0]
      @state_abbrev = state_record[1]

      # Return a link to the object so that methods can be chained
      self
    end

  private

    def sample(list)
      # Isolate random sampling so that all values use the 
      # same (repeatable) seed value if specified
      list[@prng.rand(list.length)]
    end

  end

end
```

After reloading the *customers* table using our new generators; in the image below, we can now see the correct pairing between capital and state.

![Image of City Match](/images/posts/generating-test-data-for-rails-projects-06.png)

## Conclusion

We have accomplished a lot in just this first pass. We started with a Rails project that we wanted to generate test data for. We then used ActiveRecord, outside of a Rails project, to retrieve a list of tables and the columns for those tables. Then we decided on using YAML to store our configuration data, due to its easy readability and Ruby's built-in support for serializing objects to and from it. Next we created a simple string generator, that while accomplishing our initial goal, was not very pretty to look at. We then refined our basic generator with more specific generators for common data fields such as names and addresses. To make the data more customizable we moved it out of our classes and into separate files, stored by country code. Finally we modified our improved generators so that they maintained state, allowing us to produce more cohesive data for related fields such as cities, states, and names.

### Next Steps

So where do we go from here? Well, to start, we need a lot more generators to cover the different kinds of data that we might want to create such as random text paragraphs for descriptions, ip addresses, company names, or unique employee ids. Also the generators could be made more intelligent, where they could refer to other fields within the current record when making decisions about data to generate. One big issue with our current setup is that we don't have an easy way of incorporating foreign key relationships exposed by the *has_many* and *belongs_to* ActiveRecord association types.

So you can see that we have only just begun. If you would like to see the application so far and contribute to its growth, check out the project at [GitHub](https://github.com/tjchester/gendata). Have fun!
