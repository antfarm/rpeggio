#!/usr/bin/env jruby

#
#  motorik.rb
#

require './class.looper.rb'
require './class.synthesizer.rb'

# looper parameters

NUM_TICKS = 1000000
TICK_TIME = 15000 / (BPM = 120)

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
  
  synth.drum(:phh,     100, 12)
  synth.drum(:snare1, 90, 12) if tick % 4 == 2
  synth.drum(:kick2,  130, 12) if tick % 4 != 2
  
  synth.drum(:cowbell,  100, 12) if tick % 4 == 0
  
  # synth.random_drum(tick)

  synth.print_notes
  
end
