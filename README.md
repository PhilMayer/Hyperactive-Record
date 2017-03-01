# Hyperactive-Record
Hyperactive Record is a ligthweight version of Active Record. It abstracts away good old fashioned SQL queries into a simple and developer-friendly set of methods for querying by columns names and for creating associations between different database tables.

## Defining getter and setter methods
New classes inheriting from SQLObject use the `finalize!` method to iterate through the classes's table's columns and then...wait for it...employ *metaprogramming* to define getter and setter methods for the columns on the fly. It's all extremely clever and compact. To wit:

`self.columns.each do |column|
      define_method(column) { attributes[column] }
      define_method("#{column}=") { |value| attributes[column] = value }
    end`

## The Searchable module
SQLObject extends Searchable, thus rendering the `where` method available on all classes inheriting from SQL Object. `where` takes any number of parameters in a hash and then splats the living hell out of the param's values when carrying out the actual SQL query.

## The Associatable module
SQLObject similarly extends Associatable, making available the indispensible `belongs_to` and `has_many methods` for leaping gracefully between database tables. These methods also `define_method`s for the association of your choosing. They then use default values for foreign keys, primary keys and class names based on the given association name. That is, unless values are given for `primary key`, `foreign key` or `class_name`, at which point the defaults are overriden like a bad lunch suggestion.

##
