require './relation_db'

def relation_attributes
  puts "Enter the names of the attributes:(e.g. ABCD indicates 4 atributes A thru D)"
  attributes = gets.strip.upcase
  relation_attributes unless is_albhabet(attributes)
  attributes
end

def fds
  puts "Enter the set of FDs: eg: A->B, C->D"
  gets.strip.upcase.split(',').map(&:strip)
end

def is_albhabet(attributes)
  !attributes.empty? && !attributes.match(/^[A-Za-z]+$/).nil?
end

#Initialize user provided relation atrributes and FDs 
# Eg: Realtion Attributes: ABCDEF
# FDS: A->C, AB->B,  A->F, AB->CD, C->B
rdb = RelationDB.new(relation_attributes, fds)
p "Valid FDS: #{rdb.fds.join(', ')}"

# Compute closure of user provided set of attributes as seed
# User can exit by typing 'quit'.
while true
  puts "Enter the seed:(type quit to exit)"
  seed = gets.strip.upcase
  break if seed == 'QUIT'
  p "Closure of #{seed}: { #{rdb.closure(seed).join(', ')} }"
end

# Compute Keys of the table
keys = rdb.keys().join(', ')
p "Keys: #{keys}"
p

#Normal Form of the table
normal_form = rdb.normal_form()
p "Normal Form: #{normal_form}"
p

