
require "metronome/configuration"
require "metronome/task"
require "metronome/provisioner"

require "metronome/engine" if defined?(Rails)

def Metronome(&config)
  Metronome.global.tap { |c| c.configure(&config) }
end

module Metronome

  def self.global
    @global ||= Metronome::Configuration.new
  end

end

