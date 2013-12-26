#
#  Looper
#  (sean@antfarm.de)
#

require 'java'

#
#  Looper
#

class Looper

  attr_reader :tick
  attr_accessor :tick_time
  
  # call block every tick_time milliseconds for num_tick times
  
  def loop(num_ticks, tick_time)
    @tick_time = tick_time
    
    (0..num_ticks).each do |tick|
      time = java.lang.System.currentTimeMillis

      @tick = tick
      yield tick

      sleep_time = @tick_time - (java.lang.System.currentTimeMillis - time)
      java.lang.Thread.sleep(sleep_time) if sleep_time > 0
    end
  end
  
end
