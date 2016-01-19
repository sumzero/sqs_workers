require_relative  'sqs_workers/manager'
require_relative  'sqs_workers/worker_base'
require_relative  'sqs_workers/worker'
require_relative  'sqs_workers/runner'
require_relative  'sqs_workers/version'

module SqsWorkers
	def self.config
		@config ||= { worker_root: ".", queue_prefix: "", redis_config: {}}
	end

	def self.configure
		yield config
	end
end
