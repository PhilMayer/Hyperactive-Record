require_relative 'db_connection'
require_relative '01_sql_object'

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

    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
