# RelationalDatabase

Ruby program that computes the Closure, Keys and the Normal Form of the table based on the user provided relation attributes and FDs.

Usage:

To run the program:
`
  ruby relational_db.rb
`

User will be prompted to enter the relation attributes(upper case single characters eg. ABCD) and the set of FDs(eg: A->B; B->C). The program identifies and ignores all trivial FDs, such as AB->B, wrong FDs, such as A->F (if the input attributes are ABCD) and superfluous ones such as AB->C with A->B already there. Repeated FDs are also identified and ignored. Any FDs that are not in the standard non-trivial forms are changed to non-trival, e.g., AB->CD is translated into standard non-trivial forms AB->C and AB->D. 

To compute the closure, user is asked to enter any set of attributes as the seed. Users can compute as many closure as they want until they type 'quit'. 

The program outputs the Keys and the Normal Form designation for the table computed based on the FD's.






