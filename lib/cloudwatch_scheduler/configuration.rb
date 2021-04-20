# frozen_string_literal: true

require "active_support/core_ext/numeric/time"

module CloudwatchScheduler
  class Configuration
    attr_accessor :queue_visibility_timeout,
                  :queue_max_receive_count,
                  :use_dead_letter_queue

    attr_reader :tasks

    def initialize
      @tasks = {}
      set_defaults
    end

    def configure(&config)
      instance_exec(self, &config)
      self
    end

    def task(name, **kwargs, &task)
      @tasks[name] = Task.new(name, **kwargs, &task)
    end

    def set_defaults
      @queue_visibility_timeout = 1.minute
      @queue_max_receive_count  = 2
      @use_dead_letter_queue    = true
    end

    attr_writer :queue_name

    def queue_name
      @queue_name ||= CloudwatchScheduler::Job.queue_name
    end
  end
end
