module Dyco
  class Table
    def initialize(table, declarations)
      columns = table.to_a

      @declarations = declarations
      @name         = columns.detect{|pair| pair.last.nil?}.first

      raise "Missing pkey declaration for table #{name.inspect}" unless columns.detect(&method(:primary_key?))
      @pkey         = Array(columns.detect(&method(:primary_key?)).last)

      @references   = (columns.detect(&method(:foreign_keys?)) || [[]]).last
      @columns      = columns.
        reject(&method(:primary_key?)).
        reject(&method(:foreign_keys?)).
        reject{|_, value| value.nil?}.
        unshift(["id", "id"]).
        push(["created_at", "created_at"]).
        push(["created_by", "username"]).
        push(["updated_at", "updated_at"]).
        push(["updated_by", "username"])
    end

    attr_reader :name, :columns, :declarations

    def to_sql
      %Q(CREATE TABLE "#{name}"(\n    #{columns_sql.join("\n  , ")}\n\n#{pkey_sql}#{foreign_keys}#{constraints}\n);\n)
    end

    def constraints
      # TODO: Implement constraints
    end

    def columns_sql
      columns.map(&method(:column_sql))
    end

    def primary_key?(pair)
      %w(pkey).include?(pair.first)
    end

    def foreign_keys?(pair)
      %w(references).include?(pair.first)
    end

    def column_sql(column)
      name = column.first
      type = column.last
      declaration = declarations.fetch(type)

      "\"#{name}\" #{declaration.fetch("type")}#{" not null" if not_null?(declaration)}#{" default #{default(declaration)}" if default(declaration)}"
    end

    def default(declaration)
      declaration["default"]
    end

    def pkey_sql
      "  , primary key(#{@pkey.map(&:to_s).map(&:inspect).join(", ")})" if @pkey
    end

    def foreign_keys
      "\n  , #{@references.map(&method(:foreign_key)).join("\n  , ")}" if @references.any?
    end

    def foreign_key(reference)
      table_name = reference.first
      keys = Array(reference.last)
      "foreign key(#{keys.map(&:to_s).map(&:inspect).join(", ")}) references \"#{table_name}\" on update cascade"
    end

    def not_null?(declaration)
      !declaration.fetch("null")
    end
  end
end
