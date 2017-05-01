# Hyperactive-Record
Hyperactive Record is a lightweight version of Active Record. It abstracts away SQL queries into a marvelously simple set of methods for querying by columns names, updating records, and creating associations between different database tables.

## Test Driving
You can take Hyperactive Record on a spin by cloning this repo, opening up a fresh pry session and requiring the './demo.rb' file. The provided tables for cats, humans and houses can be queried like you would using good old active record: `Human.all` will give you all humans, `Human.all.last` will give you the last human in the database, and `Human.all.last.cat` will give you the last human's cat.

## Defining getter and setter methods
New classes inheriting from Hyperactive use the `finalize!` method to iterate through the classes's table's columns, defining getter and setter methods for the columns on the fly. To wit:

```ruby
self.columns.each do |column|
    define_method(column) { attributes[column] }
    define_method("#{column}=") { |value| attributes[column] = value }
  end
```

Thus, when we initialize a new instance of any child class of `Hyperactive`, we can easily set new data or retrieve existing data from its associated database table.

## The Searchable module
Hyperactive extends Searchable, thus rendering the `where` method available on all classes inheriting from SQL Object. `where` takes any number of parameters in a hash, splatting the param's values when carrying out the actual SQL query.

```ruby
module Searchable
  def where(params)
    cols_to_search = params.keys
      .map { |col| "#{col}= ?"}.join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{cols_to_search}
    SQL
```

As you might be able to glean from the above SQL query, `where` returns an array of new objects that are simply the rows that fulfill the search terms of the query.

## The Associatable module
Hyperactive similarly extends Associatable, making available the indispensable `belongs_to` and `has_many methods` for leaping gracefully between database tables. For instance, if you have one table containing information about human rights abuses, and another table containing information about certain countries, you could access all the human rights abuses of North Korea (`has_many`), or determine which country a human rights abuse belongs to.

These methods also `define_method`s for the association of your choosing. They then use default values for foreign keys, primary keys and class names based on the given association name. That is, unless values are given for `primary key`, `foreign key` or `class_name`, in which case the defaults can be overridden.
