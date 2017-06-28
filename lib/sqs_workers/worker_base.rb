require 'redis'
require 'base64'

module SqsWorkers
  class WorkerBase
    def self.queue_as(name)
      @queue_name = name.to_s
    end

    def self.fifo(fifo=false)
      @is_fifo = fifo
    end

    #arn:aws:sns:us-west-2:123456789:MyGroovyTopic
    def self.sns(sns_arn)
      @sns_arn = sns_arn.to_s
    end

    def self.queue_name
      SqsWorkers.config[:queue_prefix] + "_" + @queue_name + (self.is_fifo ? ".fifo" : "")
    end

    def self.sns_arn
      @sns_arn
    end

    def sns_arn
      self.class.sns_arn
    end

    def self.is_fifo
      @is_fifo
    end

    def is_fifo
      self.class.is_fifo
    end

    def queue_name
      self.class.queue_name
    end

    def run
      raise "run not implemented"
    end

    def self.perform_async(params)
      params[:timestamp] = Time.now #to foil duplicate testing for different messages with same parameters
      @cached_worker = self.new if @cached_worker.nil?
      @cached_worker.enqueue(params)
    end

    # Check to see if a task is duplicate
    def duplicate?(msg_hash)
      if @no_redis
        logger.error("#{self.queue_name}: Could not connect to redis, not checking for duplicate")
      end
      key_name = self.queue_name + ":" + msg_hash
      could_set = redis_client.setnx(key_name, "1")
      # If we could not set the key then it already exists, so bail
      return true if !could_set
      # Expire the key within thirty minutes (time is set in seconds)
      redis_client.expire(key_name, 60 * 30)

      return false
    rescue Redis::CannotConnectError => e
      if Rails.env.production?
        raise e
      else
        @no_redis = true
        return false
      end
    end

    def encode_message(message)
      message.to_json
    end

    def decode_message(message)
      #Hash[JSON.parse(message).map{ |k, v| [k.to_sym, v] }]
      JSON.parse(decode_base_64(message), symbolize_names: true)
    end

    def decode_base_64(message)
      #http://stackoverflow.com/questions/8571501/how-to-check-whether-the-string-is-base64-encoded-or-not
      if message.match(/^([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{4}|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)$/)
        Base64.decode64(message)
      else
        message
      end
    end

    def logger
      WorkerBase.logger
    end

    def self.logger
      return @logger if @logger
      @logger ||= Logger.new(STDOUT)
      STDOUT.sync = true
      @logger
    end

    def redis_client
      return @redis if @redis

      redis_config = SqsWorkers.config[:redis_config]

      if redis_config && redis_config[:redis_url] && redis_config[:redis_port]
        @redis ||= Redis.new(host: redis_config[:redis_url], port: redis_config[:redis_port])
      else
        @redis ||= Redis.new
      end

      @redis
    end
  end
end
