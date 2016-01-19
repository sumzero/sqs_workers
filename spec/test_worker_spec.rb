require 'spec_helper'
require 'sqs_workers/spec/test_worker'

describe SqsWorkers::Runner, :sqs do
	#connects to fake sqs server provided by the gem
	let!(:aws_config) { { region: 'us-east-1', endpoint: $fake_sqs.uri, credentials: Aws::Credentials.new("fake", "fake") } }

	it "queues an item and picks the item off of the queue" do
		Redis.new.flushall
		File.delete('out.txt') if File.exist?('out.txt')
		Aws.config.update(aws_config)
		sqs = Aws::SQS::Client.new
		#sqs.config.endpoint = $fake_sqs.uri
		sqs.create_queue(queue_name: "test_test")

		SqsWorkers.configure do |config|
			config[:aws_config] = aws_config
			config[:worker_root] = "#{Dir.pwd}/lib/sqs_workers/spec/"
			config[:queue_prefix] = "test"
			#local redis server by default
		end

		Thread.new { SqsWorkers::Runner.run }

		TestWorker.perform_async({test: "test"}) 

		wait_for(3, 0.05) { File.exist?('out.txt') }

		#let the magic happen

		expect(File.exist?('out.txt')).to eq(true)

		File.delete('out.txt') if File.exist?('out.txt')
	end

	def wait_for(time_to_wait, wait_interval)
		Timeout.timeout(time_to_wait) { sleep wait_interval until yield }
	end
end