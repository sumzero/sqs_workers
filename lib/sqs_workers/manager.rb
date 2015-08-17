module SqsWorkers
  class Manager
    attr_reader :thread_list

    def initialize
      @thread_list = []
      @worker_classes = []
      @worker_instances = []
    end

    def run
      require_workers

      @worker_classes.each do |klass|
        if klass.method_defined? :perform
          logger.info("Starting thread for #{klass}")
          @thread_list << Thread.new { klass.new.run() }          
        else
          logger.info("Skipping #{klass} as perform() is not implemented...")
        end
      end

      # Wait for all threads to finish before exiting
      @thread_list.each(&:join)
      logger.info("Waiting")
    end

    def stop
      @thread_list.each {|t| t.exit }
    end

    def logger
      return @logger if @logger
      @logger = Logger.new(STDOUT)
      STDOUT.sync = true
      @logger
    end

    # Require all worker classes in the Rails.root/app/workers
    def require_workers
      worker_files.each do |file|
        logger.info("Loading worker class: #{file}")
        cleaned_name = file.gsub(/\.rb$/,'')
        require cleaned_name
        base_file_name = File.basename(cleaned_name)
        class_name = base_file_name.gsub("_"," ").split.map(&:capitalize).join('')
        klass = Module.const_get(class_name)
        @worker_classes << klass
      end
    end

    def worker_files
      glob = File.join(SqsWorkers.config[:worker_root], "*_worker.rb")
      files = Dir.glob(glob)
    end
  end
end
