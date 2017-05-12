#!/usr/bin/env jruby  

require './class.external_synthesizer.rb'

# main

@synth = ExternalSynthesizer.new

(0...128).each do |note|
  @synth.play_note(0, note, 100)
  java.lang.Thread.sleep 100
end      
