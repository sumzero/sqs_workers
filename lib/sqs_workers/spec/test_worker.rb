class TestWorker < SqsWorkers::Worker
	queue_as :test
	
	def perform(msg)
		puts 'In Worker#perform...'
		File.open("out.txt", 'w') { |f| f.write(msg)}
    raise unless File.exist?('out.txt')
	end
end