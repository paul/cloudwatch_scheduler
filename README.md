# CloudwatchScheduler

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

Make yourself a `config/cloudwatch_scheduler.rb` file:

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

end
```

Then do `rake cloudwatch_scheduler:setup`, and CloudwatchScheduler will provision the events and
cloudwatch_scheduler queue. Then, start your Shoruken workers as normal, and the
`CloudwatchScheduler::Job` will get those events, and perform the tasks defined.

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
[clockwork]: https://github.com/tomykaira/clockwork
[cloudwatch-events]: http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/ScheduledEvents.html

