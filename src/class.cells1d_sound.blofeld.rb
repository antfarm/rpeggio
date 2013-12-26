#!/usr/bin/env jruby

require 'class.cells1d.rb'
require 'class.looper.rb'
require 'class.environment.rb'
require 'class.synthesizer.rb'
require 'class.external_synthesizer.rb'

#
#  Cells1DSound
#

class Cells1DSound < Cells1D

  attr_reader :NUM_CELLS
  attr_reader :generation
  attr_reader :cells

  #

  def initialize(channels, channel_id, params, num_rules_play, margin = 0)
    @tick = 0
    @looper = Looper.new

    @env = Environment.new(params)
    @env.listen :midi
    @env.add_listener self

    @synth = Synthesizer.new(channels)

    #
    @synth2 = ExternalSynthesizer.new     
    @history = []                                         
    #
    
    num_cells = channels[channel_id][:scale].length + 2 * margin
    super num_cells

    @channels = channels
    @channel_id = channel_id
    @play_range = {:start => margin, :end => @NUM_CELLS-1-margin}

    @NUM_RULES_PLAY = num_rules_play
  end


  def handle_environment_change(source, channel, controller, value)
    case source
    when :midi
      case channel
      when 1
        case controller
        when 1
          @looper.tick_time = @env.params(:midi, 1, 1)
        end
      end
    end
  end
  # run

  def run(num_generations)
    # pick one neighborhood state to play on the synthesizer
    setup_play_rule

    print_parameters

    @looper.loop(num_generations, @env.params(:midi, 1, 1)) do |tick|
      @generation = @looper.tick
      @cells_prev = cells

      print_state
      play_rule_expressions tick
      transition

      break if cells.eql? @cells_prev
    end
  end


  # determine which transition rules' expression is played

  def setup_play_rule
    @neighborhood_states_play = []
    (0...@NUM_RULES_PLAY).each do |n|
        @neighborhood_states_play[n] = rand @NUM_RULE_STATES
    end

    @play_rule = (0..@NUM_RULE_STATES).collect {|i| false}
    @neighborhood_states_play.each do |play|
      @play_rule[play] = true
    end
  end


  # decide whether rule expression is played

  def play_rule?(i)
    @play_rule[neighborhood_to_int(i)]
  end


  # play a note when a certain rule is expressed, pitch = cell position
  
  def play_rule_expressions(tick)
    #@synth.play_note(@channel_id, 0, rand(50)+20) if @generation % 8 == 0

    velocity = 50
    duration = 100
    #@history[tick].each { |n| @synth2.note_off(0, n, 127) } if @history[tick]
    
    @cells.each_index do |i| 
      next if i < @play_range[:start] || i > @play_range[:end]

      note = i - @play_range[:start] 

      if play_rule? i
        #@history[tick + duration] ||= []
        #@history[tick + duration] << note
        @synth2.note_on(0, note, velocity)                                   

        #@synth.play_note(@channel_id, i - @play_range[:start], rand(30)+30)
      end
    end
  end


  def print_parameters
    super
    print "play:\t"
    @neighborhood_states_play.each do |n| print n, " " end
    puts
  end

  #

  def print_state
    print @generation, "\t"
    num_notes = print_rule_expressions
    print "\t"
    #print " ", num_notes, " "
    #puts

    print_cells
  end


  def print_rule_expressions
    num_notes = 0

    print "|"
    @cells.each_index do |i|

      if play_rule?(i)
        if i >= @play_range[:start] and i <= @play_range[:end]
          num_notes += 1
          print "X"
        else
          print "x"
        end

      elsif i == @play_range[:start] or i == @play_range[:end]
        print ":"
      elsif i > @play_range[:start] and i < @play_range[:end]
        print "."
      else
        print "."
      end
    end
    print "|"
  end

end
