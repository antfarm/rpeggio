#
#  Scales
#

module Scales
  
  PATTERNS = {

    # melodic

    #               C   d   D   e   E   F   g   G   a   A   b   B   C
    :chromatic  => [0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11],
    :ionian     => [0,      2,      4,  5,      7,      9,     11],
    :ryukyu     => [0,              4,  5,      7,             11],
    :blues_min  => [0,          3,      5,  6,  7,          10   ],
    :japanese   => [0,  1,              5,          8            ],
    :third      => [0,              4,              8            ],
    :pentatonic => [0,      2,      4,          7,      9        ],
    :harm_minor => [0,      2,  3,      5,      7,  8,  9,     11],
    :klezmer    => [0,  1,          4,  5,      7,  8,         11],

    # percussive
    
    :drumkit    => [35, 36, 37, 38, 39, 40, 42, 44, 46],

    :drumkit_named => {
      :kick2   => 35,
      :kick1   => 36,
      :stick   => 37,
      :snare1  => 38,
      :clap    => 39,
      :snare2  => 40,
      :chh     => 42,
      :phh     => 44,
      :ohh     => 46,
      :cowbell => 56
    },
  }
  
  
  def self.generate(pattern_id, offset = nil, length = nil)
    return PATTERNS[pattern_id] if offset.nil?
    pattern = PATTERNS[pattern_id]
    (0...(length || pattern.length)).collect do |i| 
      ((pattern[i % pattern.length] + 12 * (i / pattern.length))  + offset) % 128
    end
  end
  
end
