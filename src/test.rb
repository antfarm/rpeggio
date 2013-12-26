#!/usr/bin/env jruby

require "class.synthesizer.rb"
require "module.scales.rb"

include Scales

#
#  test.rb
#

SYNTH_CHANNELS = {
  :drumkit       => {:channel_number => 9, :instrument_number => 0, :scale => Scales::generate(:drumkit)},
  :drumkit_named => {:channel_number => 9, :instrument_number => 0, :scale => Scales::generate(:drumkit_named)},
}

synth = Synthesizer.new(SYNTH_CHANNELS)

(1..4).each do |i|
  
  synth.play_note(:drumkit_named, :chh, 30)
  java.lang.Thread.sleep(200)
  
  synth.play_note(:drumkit, 3, 30)
  java.lang.Thread.sleep(200)

end
