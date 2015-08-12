require 'fallen'

module SqsWorkers
  module Runner
    extend Fallen

    # Overriding this method to not exit
    def self.stop!
      if @pid_file && File.exists?(@pid_file)
        pid = File.read(@pid_file).strip
        begin
          puts "Killing pid: #{pid}"
          Process.kill :INT, pid.to_i
          File.delete @pid_file
        rescue Errno::ESRCH
          STDERR.puts "No daemon is running with PID #{pid}"
        end
      else
        STDERR.puts "Couldn't find a PID file"
      end
    end

    def self.wait_for_death
      puts "waiting for process to die"
      counter = 0
      while true
        break if @pid_file.nil?
        break if !File.exists?(@pid_file)
        sleep(0.2)
        counter += 1
        if counter > 20
          puts "process did not die in #{counter * 0.2} seconds"
          return
        end
      end
      puts "process dead"
    end

    def self.run
      puts "starting"
      @manager = SqsWorkers::Manager.new
      @manager.run
    end

    def self.stop
      puts "stopping"
      @manager.stop if @manager
    end

    def self.usage
      puts "start|stop"
    end
  end
end
