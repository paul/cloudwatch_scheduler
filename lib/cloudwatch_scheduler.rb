# frozen_string_literal: true

require "cloudwatch_scheduler/configuration"
require "cloudwatch_scheduler/task"
require "cloudwatch_scheduler/provisioner"

require "cloudwatch_scheduler/engine" if defined?(Rails)

# rubocop:disable Naming/MethodName
def CloudwatchScheduler(&config)
  CloudwatchScheduler.global.tap { |c| c.configure(&config) }
end
# rubocop:enable Naming/MethodName

module CloudwatchScheduler
  def self.global
    @global ||= CloudwatchScheduler::Configuration.new
  end
end
