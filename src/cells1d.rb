#!/usr/bin/env jruby
#!/usr/bin/env java -jar ./jruby.jar

#
#  cells1d.rb
#

NUM_RUNS        = 100
NUM_GENERATIONS = 300
NUM_CELLS       = 400

CELL_STATES     = [' ', '*']
NEIGHBORHOOD    = [-1, 0, 1]

require './class.cells1d.rb'

cells = Cells1D.new(NUM_CELLS)
cells.set_parameters(CELL_STATES, NEIGHBORHOOD)

(1..NUM_RUNS).each do |r|
  print "run:\t", r, "\n"

  cells.random_cells
  #cells.set_cells((1..cells.NUM_CELLS).collect { |i| cells.NUM_CELLS/2 == i ? 1 : 0 })

  cells.random_rule
  #cells.set_rule_int 110

  cells.run NUM_GENERATIONS
  print "\n"
end

