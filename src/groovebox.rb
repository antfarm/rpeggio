#!/usr/bin/env jruby

#
#  groovebox.rb
#

require "./class.groovebox.rb"

include Scales

# environment parameters


#  rpeggio
#                                 
# f110 elastique
# 63   12   10    7   -7  |    0   127     1   123 
#


PARAMS_PRESETS = {
  :a => {:midi => { 1 => { 1 =>  62, 2 =>  4, 3 => -1,  4 => 7,  5 =>   2, 6 => 50, 7 => 15, 8 =>  0, 9 => 150 }}},
  :b => {:midi => { 1 => { 1 =>  40, 2 => 15, 3 => -31, 4 => 0,  5 =>   2, 6 => 50, 7 => 15, 8 =>  0, 9 => 150 }}},
  :c => {:midi => { 1 => { 1 => -53, 2 => 12, 3 =>  12, 4 => 0,  5 => -48, 6 => 50, 7 => 15, 8 =>  0, 9 => 150 }}},
  :d => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>  10, 4 => 0,  5 =>   3, 6 => 50, 7 => 15, 8 =>  0, 9 => 150 }}},
  :e => {:midi => { 1 => { 1 =>  28, 2 => 12, 3 =>  19, 4 => 2,  5 =>   3, 6 => 50, 7 => 15, 8 =>  0, 9 => 150 }}},
  :f => {:midi => { 1 => { 1 =>  32, 2 => 12, 3 =>  19, 4 => 5,  5 =>  -1, 6 => 50, 7 => 15, 8 =>  0, 9 => 150 }}},
  :g => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>  10, 4 => 0,  5 =>  -7, 6 => 50, 7 => 15, 8 =>  0, 9 => 150 }}},
  :h => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>  10, 4 => 0,  5 =>  -7, 6 => 50, 7 => 15, 8 =>  0, 9 => 150 }}},  
  :i => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>  16, 4 => 0,  5 =>  -7, 6 => 50, 7 => 15, 8 =>  0, 9 => 130 }}},
  :j => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>  24, 4 => 0,  5 =>  -7, 6 => 50, 7 => 15, 8 =>  0, 9 => 130 }}},
  :k => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>   7, 4 => 5,  5 =>   4, 6 => 50, 7 => 15, 8 =>  0, 9 => 130 }}},
  :l => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>  16, 4 => 7,  5 =>  -7, 6 => 50, 7 => 15, 8 =>  0, 9 => 130 }}},
  :m => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>  10, 4 => 7,  5 =>  -7, 6 => 50, 7 => 15, 8 =>  0, 9 => 130 }}},
  :n => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>  3,  4 => 12, 5 =>  10, 6 => 50, 7 => 15, 8 => 71, 9 => 130 }}},
  :o => {:midi => { 1 => { 1 =>  40, 2 => 12, 3 =>  3,  4 => 12, 5 =>  10, 6 => 50, 7 => 15, 8 => 38, 9 => 130 }}},  

  :p => {:midi => { 1 => { 1 =>  63, 2 => 12, 3 =>  10, 4 => 7,  5 =>  -7, 6 => 0,  7 => 127, 8 => 1, 9 => 123 }}},  
  
}

# box parameters

SCALE = Scales::generate(:chromatic, 0, 128)

SYNTH_CHANNELS = {
  :grand_piano => {:channel_number => 0, :instrument_number =>   1, :scale => SCALE}, 
  :bagpipe     => {:channel_number => 1, :instrument_number => 109, :scale => SCALE},
  :woodblock   => {:channel_number => 2, :instrument_number => 115, :scale => SCALE}, 
  :taiko_drum  => {:channel_number => 3, :instrument_number => 116, :scale => SCALE}, 
  :dynamic     => {:channel_number => 4, :instrument_number =>  71,  :scale => SCALE}, 
}

EVENT_PATTERNS = {
  # lead (note value increment events)
  :note_inc_1 => ":",                 # on each tick 
  :note_inc_2 => ":::..",             # tick %  5 < 3
  :note_inc_3 => ".:..:..",           # tick % 7 == 1 or tick % 7 == 4
  :note_inc_4 => "." * 16 + ":" * 16, # tick % 32 >= 16
  :note_inc_5 => "." * 32 + ":" * 32, # tick % 64 >= 32

  # Propeller
  # :note_inc_1 => ":",
  # :note_inc_2 => ".:..",
  # :note_inc_3 => "..:...",
  # :note_inc_4 => "........:",
  # :note_inc_5 => ".....:..."

  # :note_inc_1 => ":",
  # :note_inc_2 => "::..:::.",
  # :note_inc_3 => ".:.::..:..",
  # :note_inc_4 => "." * 16 + ":" * 16,
  # :note_inc_5 => "." * 32 + ":" * 32

  # drums
  #:drum_1 => ":" + "." * 31,          # tick % 32 == 0
  #:drum_2 => "....:" + "." * 27,      # tick % 32 == 4
  #:drum_3 => ":" + "." * 15,          # tick % 16 == 0
  #:drum_4 => ":...",                  # tick %  4 == 0
}

PATCHES = { # should become: event handlers per pattern (block / data ?)

  :note_increment => {            # operation: increment note value
    :note_inc_1 => [:midi, 1, 1], # event pattern id => environment parameter
    :note_inc_2 => [:midi, 1, 2],
    :note_inc_3 => [:midi, 1, 3],
    :note_inc_4 => [:midi, 1, 4],
    :note_inc_5 => [:midi, 1, 5],
  }
}

# groovebox loop

Groovebox.new(SYNTH_CHANNELS, PARAMS_PRESETS[:m], EVENT_PATTERNS, PATCHES).loop do |box|

  #if box.looper.tick % 128 == 127
  #  EVENT_PATTERNS[:note_inc_1] = ((1..5).collect {|i| rand(2) == 0 ? ":" : "."}).join
  #  #EVENT_PATTERNS[:note_inc_2] = ((1..7).collect {|i| rand(2) == 0 ? ":" : "."}).join
  #  puts
  #end

  #box.play_note(:woodblock, 49, 15) if box.play? :drum_4
  #if box.play? :drum_1
  #  (1..5).each { |n| box.looper.play_note(:taiko_drum, note - 12 + 8 * n, 10) }
  #elsif box.play? :drum_2
  #  (1..5).each { |n| box.looper.play_note(:taiko_drum, note - 6 + 8 * n, 10) }
  #elsif box.play? :drum_3
  #  box.play_note(:taiko_drum, 50, 5)
  #end
end
