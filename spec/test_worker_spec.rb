require 'spec_helper'
require 'sqs_workers/spec/test_worker'

describe SqsWorkers::Runner, :sqs do
	#connects to fake sqs server provided by the gem
	let!(:aws_config) { { use_ssl: false, sqs_endpoint: "localhost", sqs_port: 12345, access_key_id: "fake access key", secret_access_key:  "fake secret key"} }

	it "queues an item and picks the item off of the queue" do
		Redis.new.flushall
		File.delete('out.txt') if File.exist?('out.txt')
		AWS.config(aws_config)
		AWS::SQS.new.queues.create("test_test")

		SqsWorkers.configure do |config|
			config[:aws_config] = aws_config
			config[:worker_root] = "#{Dir.pwd}/lib/sqs_workers/spec/"
			config[:queue_prefix] = "test"
			#local redis server by default
		end

		TestWorker.perform_async({test: "test"}) 

		Thread.new { SqsWorkers::Runner.start! }

		#let the magic happen
		sleep 0.5

		expect(File.exist?('out.txt')).to eq(true)

		File.delete('out.txt') if File.exist?('out.txt')
	end
end