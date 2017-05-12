#!/usr/bin/env jruby

require "./class.cells1d_sound.rb"
require "./module.scales.rb"

#
#  cells1d_sound.rb
#

# ---
# kenton
# ---
#   joystick: jump/mutate rule/start_state !!!
#   ---
#   buttons: synth channel (1 per played rule expression)
#   ---
#   knob 1: instrument number
#   knob 2: scale
#   knob 3: scale offset
#   knob 4: scale length
#   ---
#   knob 5: number of cells
#   knob 6: play area width
#   knob 7: play area position
#   knob 8: volume
#   ---
#   knob 9: tempo



# synthesizer parameters

SYNTH_CHANNELS = {
  :grand_piano  => {:channel_number => 0, :instrument_number => 0,  :scale => Scales::generate(:ryukyu, 40, 20)}, 
  :japanese     => {:channel_number => 1, :instrument_number => 46, :scale => Scales::generate(:japanese, 40, 10)},
  :drumkit      => {:channel_number => 9, :instrument_number => 0,  :scale => Scales::generate(:drumkit)},
}

SYNTH_CHANNEL_PLAY = :grand_piano

#

CELL_STATES  = [" ", "|", "\\", "/"] # (1..4).collect { |i| i.to_s }
NEIGHBORHOOD = [-1, 0, 1]
 
TICK_TIME  = 100
NUM_RULES_PLAY   = 1
NUM_CELLS_MARGIN = 35

NUM_RUNS  = 100
NUM_GENERATIONS = 180

PARAMS_PRESETS = {
  :a => {:midi => { 1 => { 1 =>  100 }, 2 => {}}},
}

#

cells = Cells1DSound.new(SYNTH_CHANNELS, SYNTH_CHANNEL_PLAY, PARAMS_PRESETS[:a], NUM_RULES_PLAY, NUM_CELLS_MARGIN)
cells.set_parameters(CELL_STATES, NEIGHBORHOOD)

(0..NUM_RUNS).each do |r|
  print "run:\t", r, "\n"

  # setup CA
  cells.random_cells # cells.set_cells((1..cells.NUM_CELLS).collect { |i| cells.NUM_CELLS/2 == i ? 1 : 0 })
  cells.random_rule # cells.set_rule_int 110

  # run CA
  cells.run(NUM_GENERATIONS)
  
  print "\n"
  java.lang.Thread.sleep(800)
end
