require "spec_helper"

require "rails"
rails_version = [Rails::VERSION::MAJOR, Rails::VERSION::MINOR].join
require_relative "dummy-#{rails_version}/config/environment"


