#!/usr/bin/env jruby

#
#  midi.rb
#

require 'class.midi.rb'

class MidiListener
  def handle_midi_message(channel, controller, value)
      puts "#{channel}\t#{controller}\t#{value}"
  end
end  

midi = Midi.new
midi.add_listener(MidiListener.new)

while true do end

