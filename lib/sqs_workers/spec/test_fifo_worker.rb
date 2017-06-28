class TestFifoWorker < SqsWorkers::Worker
  queue_as :test
  fifo true

  def perform(msg)
    puts 'In FifoWorker#perform...'
    File.open("out.txt", 'w') { |f| f.write(msg)}
    raise unless File.exist?('out.txt')
  end
end