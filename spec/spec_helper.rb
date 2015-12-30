ENV['RAILS_ENV'] ||= 'test'

require "sqs_workers"
require 'fake_sqs/test_integration'
require 'byebug'

RSpec.configure do |config|
  config.before(:suite) { $fake_sqs = FakeSQS::TestIntegration.new(database: ":memory:", sqs_endpoint: "localhost", sqs_port: 12345) }
  config.before(:each, :sqs) { $fake_sqs.start }
  config.before(:each, :sqs) { $fake_sqs.reset }
  config.after(:suite) { $fake_sqs.stop if $fake_sqs }
end