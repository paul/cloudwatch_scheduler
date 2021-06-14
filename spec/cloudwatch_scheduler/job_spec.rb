# frozen_string_literal: true

require "rails_helper"

require "cloudwatch_scheduler/job"

RSpec.describe CloudwatchScheduler::Job do
  before do
    stub_const("Probe", Object.new)
    allow(Probe).to receive :call
  end

  let(:event) do
    config.tasks["test task"].event_data.stringify_keys
  end

  context "with a callable object" do
    let(:config) do
      CloudwatchScheduler.global.configure do |_config|
        task "test task", Probe, every: 1.minute
      end
    end

    it "should execute the task" do
      ActiveJob::Base.execute(event)

      expect(Probe).to have_received(:call)
    end
  end

  context "with a block" do
    let(:config) do
      CloudwatchScheduler.global.configure do |_config|
        task "test task", every: 1.minute do
          Probe.call
        end
      end
    end

    it "should execute the task" do
      ActiveJob::Base.execute(event)

      expect(Probe).to have_received(:call)
    end
  end
end
