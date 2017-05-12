#!/usr/bin/env jruby

#
#  beat.rb
#

require './class.looper.rb'
require './class.synthesizer.rb'

# looper parameters

NUM_TICKS = 1000000
TICK_TIME = 15000 / (BPM = 123)

# synthesizer

SYNTH_CHANNELS = {
  :drumkit => {:channel_number => 9, :instrument_number => 0, :scale => Scales::generate(:drumkit_named)}
}

synth = Synthesizer.new(SYNTH_CHANNELS)

def synth.drum(note, velocity, random = 0)
  play_note(:drumkit, note, velocity + rand(random))
end

def synth.random_drum(tick)
  velocity = rand(35) + (tick % 4 == 0 ? rand(30) : 0) + (tick % 12 == 0 ? 50 : 0)
  drum(random_note(:drumkit), velocity, 12)
end 

# looper behavior

looper = Looper.new

looper.loop(NUM_TICKS, TICK_TIME) do |tick|
  
  synth.drum(:phh,     25, 12) if tick % 4 == 0
  synth.drum(:chh,     45, 12) if tick % 4 == 2
  synth.drum(:snare2, 110, 12) if tick % 8 == 2
  synth.drum(:kick2,  100, 12) if tick % 16 == 0
  
  synth.random_drum(tick)

  synth.print_notes
  
end
