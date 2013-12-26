#
#  Cells1D - a simple 1-dimensional cellular automaton
#  (sean@antfarm.de)
#
#  states, neighborhood and rules are represented as follows:
#
#    CELL_STATES  = [' ', '*']
#    NEIGHBORHOOD = [-1, 0, 1]
#    RULE_110     = [0, 1, 1, 0, 1, 1, 1, 0]
#

class Cells1D

  def initialize(num_cells)
    @NUM_CELLS = num_cells
    @cells_buffer = Array.new(@NUM_CELLS)
  end

  def set_parameters(cell_states, neighborhood)
    @CELL_STATES  = cell_states
    @NEIGHBORHOOD = neighborhood

    @NUM_CELL_STATES = @CELL_STATES.length
    @NUM_NEIGHBORS   = @NEIGHBORHOOD.length
    @NUM_RULE_STATES = @NUM_CELL_STATES**@NUM_NEIGHBORS
  end

  #

  def run(num_generations)
    print_parameters
    (0..num_generations).each do |generation|
      @generation = generation
      print_cells
      @cells_prev = @cells
      transition if @generation != @NUM_GENERATIONS
      return if @cells.eql? @cells_prev
    end
  end

  #

  def transition
    # determine each cell's next state
    @cells.each_index do |i|
      # determine the state of a cell's neighborhood as a NUM_NEIGHBORS-digit base-NUM_STATES integer
      # look up the cell's new state in the rule vector
      @cells_buffer[i] = @rule[neighborhood_to_int(i)]
    end
    # perform the actual transition
    @cells = @cells_buffer.clone
  end

  # determine the state of a cell's neighborhood as a @NUM_NEIGHBORS-digit base-@NUM_STATES integer
  def neighborhood_to_int(i)
    neighborhood_int = 0
    (0...@NUM_NEIGHBORS).each do |d|
      neighbor_index = (i +  @NEIGHBORHOOD[d]) % @NUM_CELLS
      neighborhood_int += (@NUM_CELL_STATES**(@NUM_NEIGHBORS-1 - d) * @cells[neighbor_index])
    end
    # Wolfram style (111 ... 000)
    neighborhood_int = @NUM_RULE_STATES-1 - neighborhood_int
  end

  #

  def set_cells(cells)
    exit if not cells.length == @NUM_CELLS
    @cells = cells
  end

  def random_cells
    @cells = (1..@NUM_CELLS).collect { |i| rand(@NUM_CELL_STATES) }
  end

  #

  def set_rule(rule)
    exit if not rule.length == @NUM_RULE_STATES
    @rule = rule
  end

  # TODO: generalize for base-NUM_STATES integers
  def set_rule_int(rule_int)
    @rule = []
    (0...@NUM_RULE_STATES).each do |i|
      @rule[@NUM_RULE_STATES-1 - i] = (rule_int & (1 << i) != 0 ? 1 : 0)
    end
    print @rule.length
  end

  def random_rule
    @rule = (1..@NUM_RULE_STATES).collect { |i| rand(@NUM_CELL_STATES) }
  end

  #

  def print_cells
    print @generation, "\t"
    @cells.each { |cell| print @CELL_STATES[cell] }
    puts
  end

  def print_parameters
    print "states:\t", @CELL_STATES.join(' '), "\n"
    print "hood:\t",  @NEIGHBORHOOD.sort.join(' '), "\n"
    print_rule
    print "pop:\t", @cells, "\n"
  end

  def print_rule
    rule_int = 0
    (0...@NUM_RULE_STATES).each do |i|
      rule_int += (@NUM_CELL_STATES**i * @rule[@NUM_RULE_STATES-1-i])
    end
    print "rule:\t", @rule, " (", rule_int,")\n"
  end

end
