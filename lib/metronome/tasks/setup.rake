

namespace :metronome do

  desc "Create AWS Cloudwatch Event Rules for all defined tasks"
  task :setup => :environment do
    Aws.config[:logger] = Logger.new(STDOUT)
    require Rails.root.join("config/metronome")
    config = Metronome.global
    Metronome::Provisioner.new(config).provision
  end

end
