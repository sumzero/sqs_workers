$:.push File.expand_path("../lib", __FILE__)
require 'sqs_workers/version'

Gem::Specification.new do |s|
	s.name = "sqs_workers"
	s.authors = ["Conor Hunt", "Joe Siefers"]
	s.version = SqsWorkers::VERSION
	s.email = ["conor.hunt@gmail.com", "joe@sumzero.com"]
	s.description = "a helper library for enqueuing/dequeuing tasks"
	s.summary = "Makes interacting with SQS queues easier."

	s.files = Dir.glob("{lib,spec}/**/*") + %w(README.md)

	#technically, depends on rails, but will refactor this out in the future
	s.add_runtime_dependency('aws-sdk')
	s.add_runtime_dependency('redis')
	s.add_runtime_dependency('fallen')
end