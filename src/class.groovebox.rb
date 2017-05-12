#!/usr/bin/env jruby

#
#  class.groovebox.rb
#

require './class.looper.rb'
require './class.synthesizer.rb'
require './class.environment.rb'
require './class.external_synthesizer.rb'

#
#  Groovebox
#

class Groovebox

  def initialize(synth_channels, params, patterns, patches)
    @patterns = patterns
    @patches = patches

    @env = Environment.new(params)
    @env.add_listener self # observable
    @env.listen :midi      # observer

    @synth = Synthesizer.new(synth_channels)
    @synth.set_instrument(:dynamic, @env.params(:midi, 1, 8))

    @looper = Looper.new
  end

  #

  def loop
    @looper.loop(1000000, @env.params(:midi, 1, 9)) do |tick|

      @note = 0
      @patches[:note_increment].each_pair do |pattern_id, controller_info|
        if play? pattern_id
          source_id, channel_id, controller_id = controller_info
          @note += @env.params(source_id, channel_id, controller_id)
        end
      end
      @note = [[@note, @synth.channel_scales[:dynamic].length].min, 0].max

      velocity = [[@env.params(:midi, 1, 6) + rand(@env.params(:midi, 1, 7)), 127].min, 0].max

      @synth.clear
      @synth.play_note(:dynamic, @note, [[velocity, 127].min, 0].max)

      #
      # duration = @env.params(:midi, 1, 8);
      # note = @synth.channel_scales[:dynamic][@note]
      #
      # @synth2 ||= ExternalSynthesizer.new
      # @history ||= []
      # @history[tick].each { |n| @synth2.note_off(0, n, 127) } if @history[tick]
      # @history[tick + duration] ||= []
      # @history[tick + duration] << note
      # @synth2.note_on(0, note, velocity)
      #

      print_state

      yield self
    end
  end

  # patterns

  def play?(pattern_id)
    @patterns[pattern_id][@looper.tick % @patterns[pattern_id].size] == ":" #58 # 58 -> ':'
  end

  def mutate_pattern(pattern_id, mutation_rate = 0.1)
    pattern_length = @patterns[pattern_id].length
    (0..pattern_length).each do |i|
      if rand(100) < 100 * mutation_rate
        @patterns[pattern_id][i] = (@patterns[pattern_id][i] == 58 ? "." : ":") # 58 -> ':'
      end
    end
  end

  # input

  def handle_environment_change(source, channel, controller, value)
    case source
    when :midi
      case channel
      when 1
        @env.wrap_params(source, channel, controller, 128) if 6 <= controller && controller <= 8
        mutate_pattern(@patterns.keys[controller - 10]) if 10 <= controller && controller <= 14
        case controller
        when 8
          @synth.set_instrument(:dynamic, @env.params(source, channel, controller))
        when 9
          @looper.tick_time = @env.params(:midi, 1, 9)
        end
      end
    end
  end

  # graphics

  def print_state
    printf("%3d", @note)
    print "  "

    #print ":"
    #(@patterns.keys.collect {|key| key.to_s}).sort.each do |key|
    #  if play?(key.intern)
    #    print "-" * (@env.params(:midi, 1, @patches[:note_increment][key.intern][2]) - 1)
    #    print "o"
    #  end
    #end
    #print " " * (127 - @note)
    #print ":"
    print ":#{('-' * @note)}o#{(' ' * (127 - @note))}:"

    print "  | "
    (@patterns.keys.collect {|key| key.to_s}).sort.each do |key|
      format = play?(key.intern) ? " %3d " : "     "
      print sprintf(format, @env.params(:midi, 1, @patches[:note_increment][key.intern][2]))
    end
    print " | "

    [6, 7, 8, 9].each { |cc| printf "%4d  ", @env.params(:midi, 1, cc)}

    print "  "
    print @synth.instrument_names[@env.params(:midi, 1, 8)]
    puts
  end
end
