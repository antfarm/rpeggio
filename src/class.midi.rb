#
#  Midi - a simple MIDI interface
#  (sean@antfarm.de)
#

require 'java'

#
#  Midi
#

class Midi

  # implements interface Receiver

  include javax.sound.midi.Receiver

  #

  def initialize
    # listeners
    @listeners = []

    # devices
    info = javax.sound.midi.MidiSystem.midiDeviceInfo
    #info.each { |device| puts device }

    # exit if not enough devices
    java.lang.System.exit 0 if info.length < 1

    # setup devices
    devices = []
    [0].each do |i|
      devices[i] = javax.sound.midi.MidiSystem.getMidiDevice info[i]
      devices[i].open
      devices[i].transmitter.receiver = self
      #puts devices[i]
    end
  end

  #

  def add_listener(listener)
    @listeners << listener if listener.respond_to? :handle_midi_message
  end

  def notify_listeners(channel, controller, value)
    @listeners.each do |listener|
      listener.handle_midi_message(channel, controller, value)
    end
  end


  # javax.sound.midi.Receiver.send

  def send(message, timestamp)
    # message data
    bytes = message.getMessage

    channel = bytes[0] + 0x51
    controller, value = bytes[1], bytes[2]

    # # Doepfer type
    # if value < 10
    #   controller, value = value, controller
    #   value = (value == 96 ? 1 : -1)
    # end

    # Ableton signed 7 bit mode
    value = (value <= 64 ? 1 : -1)

    notify_listeners(channel, map_controller(channel, controller), value)
  end

  #

  def close
    # TODO
  end

  #

  def map_controller(channel, controller)
    return controller

    # Evolution X-Session
    if channel == 1
      if controller >= 16 and controller <= 31
        controller -= 15 # knobs     => controller 1 ... 16
      elsif controller == 10
        controller = 17  # fader     => controller 17
      elsif controller >= 14 and controller <= 15
        controller += 4  # keys 0,1  => controller 18, 19
      elsif controller >= 85 and controller <= 90
        controller -= 65 # keys 2-7  => controller 20 ... 25
      elsif controller >= 118 and controller <= 119
        controller -= 92 # keys 8,9  => controller 26 ... 27
      end
    # Doepfer Pocket Dial
    elsif channel == 2
      controller += 1
    end
    controller
  end

end
