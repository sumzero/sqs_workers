Note: in the time since this gem was originally developed, new and better solutions have been developed that are compatible with ActiveJob. Check out: https://github.com/phstc/shoryuken

# sqs_workers

This gem provides a convenient framework for working with SQS queues in Rails. It relies upon a working redis server to guarantee message idempotency.

###Configuration
You'll want to add an initializer `config/initializers/sqs_workers.rb` like the following:
```ruby
queue_prefix, redis_config = if Rails.env.production?
	['prod', {redis_url: "some/url/goes/here", redis_port: 6379}]
elsif Rails.env.test?
	['test', {}]
elsif Rails.env.development?
	['dev', {redis_url: "127.0.0.1", redis_port: 6379}]
end

aws_config = {region: 'us-east-1', credentials: Aws::Credentials.new("access_key", "secret_key") }
Aws.config.update(aws_config)

SqsWorkers.configure do |config|
	config[:worker_root] = "#{Rails.root}/app/workers/"
	config[:queue_prefix] = queue_prefix
	config[:redis_config] = redis_config
end
```
The `queue_prefix` allows you to have different queue names depending on your environment (if you so choose). For example, `dev_queue` vs `prod_queue`.

###Message Consumption
Worker classes are automatically loaded from `app/workers` (as defined in your config file above) and implement the `perform` method as shown below.
```ruby
require 'sqs_workers'

class GruntWorker < SqsWorkers::Worker
	queue_as :grunt

	def perform(msg)
		ActiveRecord::Base.connection_pool.with_connection do |conn|
      			grunt = Grunt.find(msg[:id])
      			puts "Grunt id: #{msg[:id]}: Your command, master."
      			grunt.zug_zug()
      			puts "Zug Zug"
		end
	end
end
```

###Message Publication

```ruby
  GruntWorker.perform_async({id: 1})
```

###Publishing A New Gem Version
1. Change the version.rb value according to semantic versioning rules
2. Run gem build sqs_workers.gemspec
3. Commit all changed files

