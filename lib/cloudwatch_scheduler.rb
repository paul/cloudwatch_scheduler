
require "cloudwatch_scheduler/configuration"
require "cloudwatch_scheduler/task"
require "cloudwatch_scheduler/provisioner"

require "cloudwatch_scheduler/engine" if defined?(Rails)

def CloudwatchScheduler(&config)
  CloudwatchScheduler.global.tap { |c| c.configure(&config) }
end

module CloudwatchScheduler

  def self.global
    @global ||= CloudwatchScheduler::Configuration.new
  end

end

