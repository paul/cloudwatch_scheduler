module CloudwatchScheduler
  class Job < ::ApplicationJob
    # :ProductionScheduledJobs or :BetaScheduledJobs
    queue_as "#{Rails.env.titlecase}ScheduledJobs".to_sym

    def initialize(config: CloudwatchScheduler.global)
      @config = config
    end

    def perform(job_to_spawn)
      @config.tasks[job_to_spawn].invoke
    end

  end
end
