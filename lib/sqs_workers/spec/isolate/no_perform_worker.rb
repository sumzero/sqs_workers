class NoPerformWorker < SqsWorkers::Worker
	queue_as :no_perform
end