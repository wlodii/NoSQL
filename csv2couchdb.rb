require 'rubygems'
require 'json'
require 'couchrest'
file = File.open("software", "r")
baza = CouchRest.database!('http://127.0.0.1:5984/bazasoft')

# nagłówki
keys = file.readline().chomp!.split(",")
values = []
result = []

# parsowanie
file.each_line do | line |
  iter = 0
  assoc = {}
  line.chomp.split(",").each do |v|
    assoc[keys[iter]] = v
    iter += 1
  end
  result.push(assoc)

end


puts result


baza.bulk_save(result)

