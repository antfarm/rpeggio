#
#  Synthesizer - a simple MIDI synthesizer
#  (sean@antfarm.de)
#

require 'java'

require 'module.scales.rb'

#
#  Synthesizer
#

class Synthesizer

  attr_reader :channel_notes, :instrument_names
  attr_reader :channel_scales
  
  
  def initialize(channel_info)
    
    devices = javax.sound.midi.MidiSystem.getMidiDeviceInfo
    devices.each { |i| p i }
    #exit
    
    @synth = javax.sound.midi.MidiSystem.synthesizer
    @synth.open
    
    @instrument_names =  @synth.availableInstruments.collect { |i| i.name }
   
    @channel_ids = []
    
    @channels = {}
    @channel_notes = {}
    @channel_scales = {}
   
    channel_info.each do |channel_id, channel_info|
      # collect channel ids
      @channel_ids.push(channel_id)
      
      # initialize channel
      @channels[channel_id] = @synth.channels[channel_info[:channel_number]]
      @channels[channel_id].programChange(channel_info[:instrument_number])
    
      # initialize channel's scale
      @channel_scales[channel_id] = channel_info[:scale]
      
      # initialize channel's notes queue (max. polyphony)
      @channel_notes[channel_id] = []
    end
  end  


  def clear
    @channel_ids.each do |channel_id|
      #flush the queue
      @channel_notes[channel_id] = []
      # stop playing any notes
      @channels[channel_id].allNotesOff
    end
  end
  

  def play_note(channel_id, scale_index, velocity)
    # apply scale
    pitch = @channel_scales[channel_id][scale_index]
    return if pitch.nil?
    
    # if the note is currently played, stop playing it and remove it from the queue
    if @channel_notes[channel_id].include? pitch
      @channel_notes[channel_id].delete pitch
      @channels[channel_id].noteOff(pitch) 
    end
    
    # if max. polyphony is reached, stop the oldest note and remove it from the queue
    if @channel_notes[channel_id].length == @synth.getMaxPolyphony
      @channels[channel_id].noteOff(@channel_notes[channel_id].pop) 
    end
    
    # push the note into the queue and play it
    @channel_notes[channel_id].unshift pitch
    @channels[channel_id].noteOn(pitch, velocity)
  end

  # retrieve a random note on a given channel
  def random_note(channel_id)
    pattern = @channel_scales[channel_id]
    pattern.keys[rand(pattern.length)]
  end

  def set_instrument(channel_id, instrument_number)
    @channels[channel_id].programChange(instrument_number)
  end

  # print all currently playing notes
  def print_notes
    p @channel_notes
  end

  def print_info
    print "[bank]\t[program]\t[name]\n"

    @synth.availableInstruments.each do |i| 
      print i.patch.bank, "\t", i.patch.program, "\t", i.name, "\n" 
    end
    
    print "# channels: ", @channels.length, "\n"
    print "polyphony:  ", @synth.getMaxPolyphony, "\n"
  end
  
end
