class TestSnsWorker < SqsWorkers::Worker
  queue_as :sns
  sns "arn:aws:sns:us-east-1:569640145517:dev_pricing_events"

  #overrides super for testing purposes to isolate from SQS
  def run

  end
  
  #included so manager picks us up
  def perform

  end
end