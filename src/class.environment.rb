#
#  Environment - a container for controller states
#  (sean@antfarm.de)
#

require './class.midi.rb'

#
#  Environment
#


class Environment

  def initialize(params)
    @params = params
    @listeners = [] # playthrough of environment signals
  end

  # listeners will receive incoming environment signals, e.g. from a midi controller

  def add_listener(listener)
    @listeners << listener if listener.respond_to? :handle_environment_change
  end

  def notify_listeners(source, channel, controller, value)
    @listeners.each do |listener|
      listener.handle_environment_change(source, channel, controller, value)
    end
  end

  # listen to controller/sensor signals

  def listen(source)
    case source
    when :midi
      @midi = Midi.new
      @midi.add_listener(self)
    end
  end

  #

  def handle_midi_message(channel, controller, value)
    @params[:midi][channel][controller] += value if @params[:midi][channel][controller]
    notify_listeners(:midi, channel, controller, value)
  end

  #

  def params(source, channel, index)
    @params[source][channel][index]
  end

  def set_params(source, channel, index, value)
    @params[source][channel][index] = value
  end

  def wrap_params(source, channel, index, max)
    @params[source][channel][index] = (@params[source][channel][index] + max) % max
  end

end
