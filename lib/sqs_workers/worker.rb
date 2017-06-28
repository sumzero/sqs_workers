require 'aws-sdk'

module SqsWorkers
  class Worker < WorkerBase

    def enqueue(options)
      if self.sns_arn
        sns_topic.publish(message: encode_message(options))
      else
        sqs_client.send_message(queue_url: queue_url, message_body: encode_message(options))
      end
    end

    def run
      logger.info("#{self.queue_name}: Starting polling for: #{self.queue_name}")

      poller.poll do |msg, stats|
        print_queue_stats(stats)
        logger.debug("#{self.queue_name}: Received message: #{msg.message_id} : #{msg.body}")
        next if duplicate?(msg)
        logger.debug("#{self.queue_name}: Processing message: #{msg.message_id}")
        begin
          #TODO: how to do connection pooling in ActiveRecord?
          perform(decode_message(msg.body))
        rescue StandardError => e
          logger.error("Error processing message #{msg.message_id} : #{e} : #{e.backtrace.join('\n')}")
        rescue Exception => e
          logger.error("Exception: #{e} : #{e.backtrace.join('\n')}")
        ensure
          logger.debug("#{self.queue_name}: Finished with message: #{msg.message_id}")
        end
      end

      logger.debug("#{self.queue_name}: Exited poller.poll()")
    end

    def print_queue_stats(stats)
      logger.debug("#{self.queue_name}: Requests: #{stats.request_count}")
      logger.debug("#{self.queue_name}: Messages: #{stats.received_message_count}")
      logger.debug("#{self.queue_name}: Last-timestamp: #{stats.last_message_received_at}")
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

    def sns
      @sns = Aws::SNS::Resource.new(SqsWorkers.config[:aws_config][:region])
    end

    def sns_topic
      @sns_topic ||= sns.topic(self.sns_arn)
    end

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(SqsWorkers.config[:aws_config][:region])
    end

    def queue_url
        @queue_url ||= sqs_client.get_queue_url(queue_name: self.queue_name).queue_url
    end

    def poller
      @poller ||= Aws::SQS::QueuePoller.new(queue_url)
    end
  end
end
