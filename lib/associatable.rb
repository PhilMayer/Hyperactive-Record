require_relative 'searchable'
require 'active_support/inflector'
require 'byebug'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase
    @foreign_key = options[:foreign_key] || (name.to_s.underscore + "_id").to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.singularize.capitalize
    @foreign_key = options[:foreign_key] ||
    (self_class_name.downcase.underscore + "_id").to_sym
  end
end

module Associatable
  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      foreign_key = self.send(options.foreign_key)

      options.model_class.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      primary_key = self.send(options.primary_key)

      options.model_class.where(options.foreign_key => primary_key)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      source_table = source_options.table_name
      through_table = through_options.table_name

      through_primary_key = through_options.primary_key
      through_foreign_key = through_options.foreign_key
      source_primary_key = source_options.primary_key
      source_foreign_key = source_options.foreign_key

      id = self.send(through_foreign_key)

      results = DBConnection.execute(<<-SQL, id)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
        WHERE
          #{through_table}.#{through_primary_key} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end

  def assoc_options
    @assoc_options ||= Hash.new
  end
end

class Hyperactive
  extend Associatable
end
