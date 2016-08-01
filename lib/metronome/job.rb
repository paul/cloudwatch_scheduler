module Metronome
  class Job < ::ApplicationJob
    queue_as :metronome

    def perform(job_to_spawn)
      job_to_spawn.constantize.perform_later
    end

  end
end
