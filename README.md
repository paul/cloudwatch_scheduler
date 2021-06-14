# CloudwatchScheduler

[![Actions Status](https://github.com/paul/cloudwatch_scheduler/workflows/CI/badge.svg)](https://github.com/paul/cloudwatch_scheduler/actions)

Are you using Rails 4.2+ and ActiveJob with the [Shoryuken
driver][shoryuken-driver] to use SQS? Do you have recurring jobs that you kick
off periodically with the [amazing Clockwork gem][clockwork]? Tired of paying
for a Heroku dyno just to run the clockwork instance? Then *CloudwatchScheduler* is just
the gem for you!

CloudwatchScheduler uses [AWS Cloudwatch scheduled event rules][cloudwatch-events] to
push a message on the cloudwatch_scheduler queue according to the schedule you provide,
using a simple DSL similar to the Clockwork DSL you're already familiar with.
The rules are free, and the messages cost a few billionths of a cent each,
saving you over $25/mo in Heroku dyno costs! Wow!!

And thats not all! It will automatically provision the Cloudwatch Events and Queues via a simple rake task! Amazing!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloudwatch_scheduler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudwatch_scheduler

## Usage

Make yourself a `config/cloudwatch_schedule.rb` file:

```ruby
require "cloudwatch_scheduler"

CloudwatchScheduler do |config|

  # 4am every day
  task "spawn_analytics_jobs", cron: "0 4 * * ? *" do
    return if Rails.application.config.deploy_env.sandbox?
    AnalyticsSpawnerJob.perform_later
  end

  task "capture_pg_stats", every: 5.minutes do
    PgHero.capture_query_stats
  end

  # Instead of a block, you can provide any object that responds to `#call`
  task "collect_analytics", AnalyticsCollector.new, cron: "*/15 6-18 * * *"
end
```

By default, the Cloudwatch will put events on the `cloudwatch_scheduler` queue
(possibly modified with a prefix from your Shoryuken config). To use a
different queue, CloudwatchScheduler supports some configuration:

```ruby
CloudwatchScheduler do |config|
  # Queue name to use for events. If you have your Shoryken configured to
  # prefix queue names (eg, `production_my_queue`), that will be respected here
  # as well
  config.queue_name               = :my_queue # default `cloudwatch_scheduler`

  # SQS Visibility Timeout - how long will the job be allowed to be worked
  # before being made available for retry. This should be (much) shorter than
  # the shortest interval between runs of a scheduled task
  config.queue_visibility_timeout = 5.minutes # default 1.minute

  # SQS Max Receive Count - how many times can a task be retried before its
  # considered failed?
  config.queue_max_receive_count  = 5 # default 2

  # SQS dead letter queue - Move failed jobs to the dead-letter queue for later investigation or replaying?
  config.use_dead_letter_queue    = false # default true
end
```

You'll also need to inform Shoryuken about the `cloudwatch_scheduler` queue (or
whatever queue name you're using), either in the `config/shoryuken.yml` or with
`-q cloudwatch_scheduler` on the command line.

Then do `rake cloudwatch_scheduler:setup`, and CloudwatchScheduler will
provision the Cloudwatch Events and SQS Queue. Start your Shoruken workers as
normal, and the `CloudwatchScheduler::Job` will get those events, and perform
the tasks defined.

### Tips

Generally, you'll want your tasks to be as short as possible, so they don't tie
up the worker process, or fail and need to be retried. If you have more work
than can be accomplished in a few seconds, or is failure prone, then I suggest
having your scheduled task enqueue another job on a different queue. This way,
you can have different retry rules for different kinds of jobs, and the events
worker stays focused on just processing the events.

### IAM Permissions

The setup task requires some permissions in the AWS account to create the queue
and Cloudwatch Events. Here's a sample policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:CreateQueue",
        "sqs:GetQueueAttributes",
        "sqs:SetQueueAttributes",
      ],
      "Resource": [
        "arn:aws:sqs:REGION:AWS_ACCOUNT:cloudwatch_scheduler",
        "arn:aws:sqs:REGION:AWS_ACCOUNT:cloudwatch_scheduler-failures"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "events:PutRule",
        "events:PutTargets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/paul/cloudwatch_scheduler.

[shoryuken-driver]: https://github.com/phstc/shoryuken/wiki/Rails-Integration-Active-Job
[clockwork]: https://rubygems.org/gems/clockwork
[cloudwatch-events]: http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/ScheduledEvents.html

