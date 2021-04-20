# frozen_string_literal: true

require "rails_helper"

require "cloudwatch_scheduler/job"

RSpec.describe CloudwatchScheduler::Job do
  class Probe
    include Singleton

    attr_reader :called

    def initialize
      @called = false
    end

    def call
      @called = true
    end
  end

  let(:config) do
    CloudwatchScheduler.global.configure do |_config|
      task "test task", every: 1.minute do
        Probe.instance.call
      end
    end
  end

  let(:event) do
    config.tasks["test task"].event_data.stringify_keys
  end

  it "should execute the task" do
    ActiveJob::Base.execute(event)

    expect(Probe.instance.called).to be true
  end
end
