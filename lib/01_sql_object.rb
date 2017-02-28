require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    @columns || query_for_column_names = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        1
    SQL

    @columns ||= query_for_column_names[0]
      .map{ |column| column.to_sym }
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) { attributes[column] }
      define_method("#{column}=") { |value| attributes[column] = value }
    end
    @attributes
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || (self.name.downcase + "s").tableize
  end

  def self.all
    all_rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL

    parse_all(all_rows)
  end


  def self.parse_all(all_rows)
    all_rows.map { |row| self.new(row) }
  end

  def self.find(id)
    entry = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    parse_all(entry).first
  end

  def initialize(params = {})
    params.each do |col, val|
      col = col.to_sym
      raise "unknown attribute '#{col}'" unless self.class.columns.include?(col)
      self.send("#{col}=", val)
    end
  end

  def attributes
    @attributes ||= Hash.new
  end

  def attribute_values
   self.class.columns.map { |col| self.send(col) }
 end

 def insert
   col_names = self.class.columns
   q_marks = ["?"] * col_names.length

   DBConnection.execute(<<-SQL, *attribute_values)
     INSERT INTO
       #{self.class.table_name} (#{col_names.join(",")})
     VALUES
       (#{q_marks.join(",")})
   SQL

   self.id = DBConnection.last_insert_row_id
 end

  def update
    args = attribute_values
    cols_to_set = self.class.columns
      .map {|name| "#{name} = ?"}.join(",")

    DBConnection.execute(<<-SQL, *args, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{cols_to_set}
      WHERE
        id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
