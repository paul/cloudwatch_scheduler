# frozen_string_literal: true

module CloudwatchScheduler
  class Job < ::ApplicationJob
    queue_as :cloudwatch_scheduler

    def initialize(config: CloudwatchScheduler.global)
      @config = config
    end

    def perform(job_to_spawn)
      @config.tasks[job_to_spawn].invoke
    end
  end
end
