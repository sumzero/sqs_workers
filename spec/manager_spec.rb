require 'spec_helper'
require 'sqs_workers/spec/isolate/empty_run_worker'
require 'sqs_workers/spec/isolate/no_perform_worker'

#this should probably be refactored to allow for better testing, it's kind of a hack right now...
describe SqsWorkers::Manager do
	context "#run" do
		it "doesn't create threads for workers without a perform defined" do
			SqsWorkers.configure do |config|
				config[:worker_root] = "#{Dir.pwd}/lib/sqs_workers/spec/isolate"
			end

			manager = SqsWorkers::Manager.new

			#check that we only create threads for one of the two worker classes
			expect {
				manager.run
			}.to change { manager.thread_list.count }.by(1)
		end
	end
end