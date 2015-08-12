class TestWorker < SqsWorkers::Worker
	queue_as :test
	
	def perform(msg)
		File.open("out.txt", 'w') { |f| f.write(msg)}
	end
end