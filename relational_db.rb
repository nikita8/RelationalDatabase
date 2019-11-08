require './relation'

def relation_attributes
  p "Enter the names of the attributes:(e.g. ABCD indicates 4 atributes A thru D)"
  attributes = gets.strip.upcase
  relation_attributes unless is_albhabet(attributes)
  attributes
end

def fds
  p "Enter the set of FDs separated by ';': eg: A->B; C->D"
  gets.strip.upcase.split(';')
end

def is_albhabet(attributes)
  !attributes.empty? && !attributes.match(/^[A-Za-z]+$/).nil?
end

# Compute closure of user provided set of attributes as seed
# User can exit by typing 'quit'.
def compute_closure(rdb)
  while true
    puts "Enter the seed:(type quit to exit)"
    seed = gets.strip.upcase
    break if seed == 'QUIT'
    p "Closure of #{seed}: { #{rdb.closure(seed).join(', ')} }"
  end
end

# Initialize user provided relation atrributes and FDs 
# Eg: Relation Attributes: ABCDEF
# FDS: A->C; AB->B;  A->F; AB->CD; C->B
rdb = Relation.new(relation_attributes, fds)
compute_closure(rdb)
keys = rdb.keys().join(', ')
normal_form = rdb.normal_form()

p "| Valid FDS: #{rdb.fds.join('; ')} |"
p "| Keys: #{keys} |"
p "| Normal Form: #{normal_form} |"

