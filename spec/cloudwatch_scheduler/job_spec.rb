require "rails_helper"

require "cloudwatch_scheduler/job"

RSpec.describe CloudwatchScheduler::Job do

  before { $probe = false }
  after  { $probe = nil }

  let(:config) do
    CloudwatchScheduler.global.configure do |config|
      task "test task", every: 1.minute do
        $probe = true
      end
    end
  end

  let(:event) do
    config.tasks["test task"].event_data.stringify_keys
  end

  it "should execute the task" do
    ActiveJob::Base.execute(event)

    expect($probe).to be true


  end

end

