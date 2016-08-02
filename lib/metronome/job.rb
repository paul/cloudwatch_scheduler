module Metronome
  class Job < ::ApplicationJob
    queue_as :metronome

    def initialize(config: Metronome.global)
      @config = config
    end

    def perform(job_to_spawn)
      @config.tasks[job_to_spawn].invoke
    end

  end
end
