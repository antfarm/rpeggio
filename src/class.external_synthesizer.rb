#!/usr/bin/env jruby  

require 'java'

class ExternalSynthesizer
  
  def initialize
    info = javax.sound.midi.MidiSystem.midiDeviceInfo
    info.each { |device| puts device }
    #javax.sound.midi.MidiSystem.getMidiDeviceInfo.each {|i| p i}
    @synth = javax.sound.midi.MidiSystem.getMidiDevice javax.sound.midi.MidiSystem.getMidiDeviceInfo[1]
    @synth.open                                       
    @msg = javax.sound.midi.ShortMessage.new    
  end
  
  def note_on(channel, note, velocity)    
    @msg.set_message(javax.sound.midi.ShortMessage::NOTE_ON, channel, note, velocity)
    @synth.send(@msg, 0)
  end

  def note_off(channel, note, velocity)   
    @msg.set_message(javax.sound.midi.ShortMessage::NOTE_OFF, channel, note, velocity)
    @synth.send(@msg, 0)
  end
  
end
