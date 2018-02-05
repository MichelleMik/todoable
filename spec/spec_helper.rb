require "bundler/setup"
require "todoable"
require 'securerandom'
require_relative '../lib/todoable.rb'
require_relative '../lib/todoable/items'
require_relative '../lib/todoable/lists'
require_relative '../lib/todoable/error_parser'


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
