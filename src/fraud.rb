#!/usr/bin/env jruby

#
#  fraud.rb
#

require 'class.looper.rb'
require 'class.synthesizer.rb'

# instruments and scales (cf. http://en.wikipedia.org/wiki/General_MIDI)

SYNTH_CHANNELS = {
  :grand_piano_full => {:channel_number => 0, :instrument_number => 0, :scale => Scales::generate(:chromatic, 50, 128)}, 
  :grand_piano_japanese => {:channel_number => 0, :instrument_number => 0, :scale => Scales::generate(:japanese, 40, 20)}, 
  :grand_piano_blues_min => {:channel_number => 0, :instrument_number => 0, :scale => Scales::generate(:blues_min, 40, 20)}, 
  :japanese_wood    => {:channel_number => 1, :instrument_number => 115, :scale => Scales::generate(:japanese, 40, 20)}, 
  :grand_piano      => {:channel_number => 0, :instrument_number =>0,  :scale => Scales::generate(:japanese, 35, 20)},
  :bass             => {:channel_number => 0, :instrument_number => 0,  :scale => Scales::generate(:ryukyu, 40, 20)},
  :drumkit          => {:channel_number => 9, :instrument_number => 0, :scale => Scales::generate(:drumkit, 0, 20)}
}


# read file

filename = '../data/spammusik.txt'
file = File.new(filename, 'r')

pagelets = Array.new
keys = Array.new
values = Array.new
max_value = 0

file.each_line("\n") do |row|
  bytes = row.split(".").map { |b| b.to_i }
  hash = {}

  (0..3).each do |i| 
    key = bytes[i]
    next if key == 0
    keys << key unless keys.include? key
    
    value = bytes[i+4]
    max_value = value if value > max_value
    values << value unless values.include? value
    
    hash[key] = value
  end

  pagelets << hash
end

# keys.sort! { |k1, k2| k2 <=> k1 }
keys.sort! { |k1, k2| k1 <=> k2 }

print "keys: "
p keys
print "values: "
p values

key_map = {}
(0...keys.size).each do |i|
  key_map[keys[i]] = i
end

print "key_map: " 
p key_map

# exit


# pagelets.each { |pagelet| p pagelet }

# looper behavior

TICK_TIME = 150 # 150 = 400 bpm
NUM_TICKS = pagelets.length

synth = Synthesizer.new(SYNTH_CHANNELS)
channel = :grand_piano
# channel = :japanese_wood
# channel = :drumkit

Looper.new.loop(NUM_TICKS, TICK_TIME) do |tick|
  notes = pagelets[tick]

  notes.each do |key, value|
    note = key_map[key] + 10
    velocity = (value * (128/max_value)).to_i
    synth.play_note(channel, note, velocity)
  end

  print "#{tick}: "
  p notes
  # synth.print_notes
end





# # read file
# 
# filename = '../data/bangladesch.txt'
# file = File.new(filename, 'r')
# 
# pagelets = Array.new
# file.each_line("\n") do |row|
#   pagelets << row.to_i
# end
# 
# 
# # looper behavior
# 
# TICK_TIME = 150 # 150 = 400 bpm
# NUM_TICKS = pagelets.length
# 
# synth = Synthesizer.new(SYNTH_CHANNELS)
# 
# Looper.new.loop(NUM_TICKS, TICK_TIME) do |tick|
#   note = pagelets[tick]
#   puts "#{tick} : #{note}"
#   synth.play_note(:drumkit, note, 70)
# end
