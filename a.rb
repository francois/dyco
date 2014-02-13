require "yaml"
require "pp"

require "dyco/table"

hash = YAML.load_file("examples/party-relationships.yml")
declarations = hash.fetch("declarations")
hash.fetch("tables").map{|h| h.to_a}.map(&:first).map(&:first).each do |table_name|
  name_functions = hash.fetch("tables").detect{|pair| pair.keys.include?(table_name)}
  table = Dyco::Table.new(name_functions, declarations)
  puts table.to_sql
  puts
end
