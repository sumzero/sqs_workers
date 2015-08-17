class EmptyRunWorker < SqsWorkers::Worker
	queue_as :empty_run

	#overrides super for testing purposes to isolate from SQS
	def run

	end

	#included so manager picks us up
	def perform

	end
end