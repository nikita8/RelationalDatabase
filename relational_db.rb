require './relation'

def relation_attributes
  while true
    puts "Enter the names of the attributes:(e.g. ABCD indicates 4 atributes A thru D)"
    attributes = gets.strip.upcase
    break if is_albhabet(attributes)
  end
  attributes
end

def fds
  puts
  puts "Enter the set of FDs separated by ';': eg: A->B; C->D"
  gets.strip.upcase.split(';')
end

def is_albhabet(attributes)
  !attributes.empty? && !attributes.match(/^[A-Za-z]+$/).nil?
end

# Compute closure of user provided set of attributes as seed
# User can exit by typing 'quit'.
def compute_closure(rdb)
  puts
  puts "Closure Operator:"
  while true
    puts "Enter any set of relation attributes as the seed:(type quit to exit)"
    seed = gets.strip.upcase
    break if seed == 'QUIT'
    closure = rdb.closure(seed)
    if closure && !closure&.empty?
      puts "Closure of #{seed}: { #{closure.join(', ')} }"
    end
  end
end

# Initialize user provided relation atrributes and FDs 
# Eg: Relation Attributes: ABCDEF
# FDS: A->C; AB->B;  A->F; AB->CD; C->B
rdb = Relation.new(relation_attributes, fds)
compute_closure(rdb)
keys = rdb.keys.join(', ')
normal_form = rdb.normal_form
puts
puts "Keys of the table: #{keys}"
puts "Table's Normal Form: #{normal_form} "
