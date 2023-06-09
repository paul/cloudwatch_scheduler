# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cloudwatch_scheduler/version"

Gem::Specification.new do |spec|
  spec.name          = "cloudwatch_scheduler"
  spec.version       = CloudwatchScheduler::VERSION
  spec.authors       = ["Paul Sadauskas"]
  spec.email         = ["psadauskas@gmail.com"]

  spec.summary       = "Use AWS CloudWatch events to trigger recurring jobs."
  spec.description   = "Use Cloudwatch Events to kick off recurring SQS ActiveJob jobs."
  spec.homepage      = "https://github.com/paul/cloudwatch_scheduler"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r(^exe/)) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency "aws-sdk-cloudwatchevents", "~> 1.13"
  spec.add_dependency "aws-sdk-sqs",              "~> 1.10"
  spec.add_dependency "rails",     ">= 5.2.0"
  spec.add_dependency "shoryuken", ">= 2.0"

  spec.add_development_dependency "bundler", ">= 1.12"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
