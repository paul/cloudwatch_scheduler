

namespace :cloudwatch_scheduler do

  desc "Create AWS Cloudwatch Event Rules for all defined tasks"
  task :setup => :environment do
    Aws.config[:logger] = Logger.new(STDOUT)
    require Rails.root.join("config/cloudwatch_scheduler")
    config = CloudwatchScheduler.global
    CloudwatchScheduler::Provisioner.new(config).provision
  end

end
