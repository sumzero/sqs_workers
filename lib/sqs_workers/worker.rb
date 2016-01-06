require 'aws-sdk'

module SqsWorkers
  class Worker < WorkerBase
    def enqueue(options)
      sqs_client.send_message(queue_url: queue_url, message_body: encode_message(options))
    end

    def run
      logger.info("#{self.queue_name}: Starting polling for: #{self.queue_name}")

      poller.poll do |msg|
        logger.debug("#{self.queue_name}: Received message: #{msg.message_id} : #{msg.body}")
        next if duplicate?(msg)
        logger.debug("#{self.queue_name}: Processing message: #{msg.message_id}")
        begin
          #TODO: how to do connection pooling in ActiveRecord?
          perform(decode_message(msg.body))
        rescue StandardError => e
          logger.error("Error processing message #{msg.message_id} : #{e} : #{e.backtrace.join('\n')}")
        end
        logger.debug("#{self.queue_name}: Finished with message: #{msg.message_id}")
      end
    end

    #checks to see if perform is implemented in child, if not, manager doesn't load worker (queueing only)
    # def perform
    #   raise "perform not implemented"
    # end

    def duplicate?(msg)
      result = super(msg.md5_of_body)
      logger.debug("#{self.queue_name}: message is dupe #{msg.message_id}") if result
      result
    end

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(SqsWorkers.config[:aws_config])
    end

    def queue_url
      @queue_url ||= sqs_client.get_queue_url(queue_name: self.queue_name).queue_url
    end

    def poller
      Aws.config.update(SqsWorkers.config[:aws_config])
      @poller ||= Aws::SQS::QueuePoller.new(queue_url)
    end
  end
end
