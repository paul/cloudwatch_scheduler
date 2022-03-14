# frozen_string_literal: true

module CloudwatchScheduler
  class Engine < Rails::Engine
    initializer "cloudwatch_scheduler.setup_job" do
      config.to_prepare do
        # Have to do this in initializer rather than require time because it
        # inherits from ApplicationJob
        require "cloudwatch_scheduler/job"

        # Explicitly register this worker, because Shoryuken expects the message
        # attributes to specify the job class, and these jobs are produced by
        # Cloudwatch Events, which provide no way to set message attributes
        Shoryuken.worker_registry.register_worker(
          CloudwatchScheduler::Job.queue_name,
          ActiveJob::QueueAdapters::ShoryukenAdapter::JobWrapper
        )

        # Load the configuration
        require Rails.root.join("config/cloudwatch_schedule").to_s
      end
    end

    rake_tasks do
      load "cloudwatch_scheduler/tasks/setup.rake"
    end
  end
end
