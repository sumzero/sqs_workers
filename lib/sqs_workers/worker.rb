require 'aws-sdk'

module SqsWorkers
  class Worker < WorkerBase
    def enqueue(options)
      sqs_queue.send_message(encode_message(options))
    end

    def run
      logger.info("#{self.queue_name}: Starting polling for: #{self.queue_name}")
      sqs_queue.poll do |msg|
        logger.debug("#{self.queue_name}: Received message: #{msg.id} : #{msg.body}")
        next if duplicate?(msg)
        logger.debug("#{self.queue_name}: Processing message: #{msg.id}")
        begin
          #TODO: how to do connection pooling in ActiveRecord?
          perform(decode_message(msg.body))
        rescue StandardError => e
          logger.error("Error processing message #{msg.id} : #{e} : #{e.backtrace.join('\n')}")
        end
      end
    end

    def perform
      raise "perform not implemented"
    end

    def duplicate?(msg)
      result = super(msg.md5)
      logger.debug("#{self.queue_name}: message is dupe #{msg.id}") if result
      result
    end

    def sqs_client
      @sqs ||= AWS::SQS.new(SqsWorkers.config[:aws_config])
    end

    def sqs_queue
      @sqs_queue ||= sqs_client.queues.named(self.queue_name)
    end
  end
end
