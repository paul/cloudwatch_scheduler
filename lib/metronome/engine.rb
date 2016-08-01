
module Metronome
  class Engine < Rails::Engine
    initializer "metronome.setup_job" do
      # Have to do this in initializer rather than require time because it
      # inherits from ApplicationJob
      require "metronome/job"

      # Explicitly register this worker, because Shoryuken expects the message
      # attributes to specify the job class, and these jobs are produced by
      # Cloudwatch Events, which provide no way to set message attributes
      Shoryuken.worker_registry.register_worker(
        Metronome::Job.queue_name,
        ActiveJob::QueueAdapters::ShoryukenAdapter::JobWrapper
      )
    end

    rake_tasks do
      load "metronome/tasks/setup.rake"
    end
  end
end
