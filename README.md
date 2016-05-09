# sqs_workers

This gem provides a convenient framework for working with SQS queues in Rails. 

To publish messages:

```ruby
  GruntWorker.perform_async({id: 1})
```

To consume messages:

```ruby
require 'sqs_workers'

class GruntWorker < SqsWorkers::Worker
	queue_as :grunt

	def perform(msg)
		ActiveRecord::Base.connection_pool.with_connection do |conn|
      grunt = Grunt.find(msg[:id])
      puts "Grunt id: #{msg[:id]}. Your command, master."
      grunt.zug_zug()
      puts "Zug Zug"
		end
	end
end
```

Environments:

SqsWorkers automatically selects the appropriate queue in SQS according to an environment prefix. For example, in development , the queue is `dev_grunt` in the above example. Similarly, in production, `prod_grunt`

To create a new version: 
1) change the version.rb value according to semantic versioning rules
2) run gem build sqs_workers.gemspec
3) commit all changed files
