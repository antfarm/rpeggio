#!/usr/bin/env jruby

#
#  oriental.rb
#

require 'class.looper.rb'
require 'class.synthesizer.rb'

# looper parameters

NUM_TICKS = 1000000
TICK_TIME = 150 # 150 = 400 bpm

SCALE = Scales::generate(:chromatic, 0, 128)#.collect { |i| (2 * i) % 128 }

SYNTH_CHANNELS = {
  :grand_piano => {:channel_number => 0, :instrument_number =>   0, :scale => SCALE},
  :bagpipe     => {:channel_number => 1, :instrument_number => 109, :scale => SCALE},
  :woodblock   => {:channel_number => 2, :instrument_number => 115, :scale => SCALE},
  :taiko_drum  => {:channel_number => 3, :instrument_number => 116, :scale => SCALE},
}

# looper behavior

synth = Synthesizer.new(SYNTH_CHANNELS)

Looper.new.loop(NUM_TICKS, TICK_TIME) do |tick|

  synth.clear

	#  melody

	note = 62
	note += 4 if tick % 5 < 3
	note -= 1 if tick % 7 == 1 or tick % 7 == 4
	note += 7 if tick % 32 >= 16
	note += 2 if tick % 64 >= 32

	synth.play_note(:grand_piano, note, rand(15))
	synth.play_note(:bagpipe, note, rand(15))

  # drums

  synth.play_note(:woodblock, 49, 15) if tick % 4 == 0

  if tick % 32 == 0
    (1..5).each { |n| synth.play_note(:taiko_drum, note-12 + 8*n, 10) }
  elsif tick % 32 == 4
    (1..5).each { |n| synth.play_note(:taiko_drum, note-6 + 8*n, 10) }
  elsif tick % 16 == 0
    synth.play_note(:taiko_drum, 50, 5)
  end

  synth.print_notes

end
