require 'redis'

module SqsWorkers
  class WorkerBase
    def self.queue_as(name)
      @queue_name = name.to_s
    end

    def self.queue_name
      SqsWorkers.config[:queue_prefix] + "_" + @queue_name
    end

    def queue_name
      self.class.queue_name
    end

    def run
      raise "run not implemented"
    end

    def self.perform_async(params)
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
      JSON.parse(message, symbolize_names: true)
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
