require 'spec_helper'
require 'sqs_workers/spec/test_worker'

describe SqsWorkers::WorkerBase do
	describe "#decode_base_64" do
		it "does not modify a non-base64 encoded string" do
			msg = "\{\"id\":11639,\"timestamp\":\"2016-02-29T15:55:24.897-05:00\"}"

			worker_base = SqsWorkers::WorkerBase.new

			expect(worker_base.decode_base_64(msg)).to eq("\{\"id\":11639,\"timestamp\":\"2016-02-29T15:55:24.897-05:00\"}")
		end

		it "converts a base64 encoded string" do
			msg = "W3siZGVsZXRlZCI6IFtdLCAibmV3IjogW3siYWN0b3IiOiAiVXNlcjo0ODQzIiwgInZlcmIiOiAiY2xvc2VfcXVpY2tfaWRlYSIsICJvYmplY3QiOiAiUmVzZWFyY2hlZENvbXBhbnk6MzAwOTIiLCAidGFyZ2V0IjogbnVsbCwgInRpbWUiOiAiMjAxNi0wMy0wMlQxNjo0Mjo1My42MTU2MjEiLCAiZm9yZWlnbl9pZCI6IG51bGwsICJpZCI6ICJjZjNhZDQzMi1lMDk1LTExZTUtODA4MC04MDAxMTQ3Yzk0Y2UiLCAidG8iOiBbXSwgIm9yaWdpbiI6ICJ1c2VyOjQ4NDMifSwgeyJhY3RvciI6ICJVc2VyOjQ4NDMiLCAidmVyYiI6ICJwdWJsaXNoX3F1aWNrX2lkZWEiLCAib2JqZWN0IjogIlJlc2VhcmNoZWRDb21wYW55OjMwMDkyIiwgInRhcmdldCI6IG51bGwsICJ0aW1lIjogIjIwMTYtMDMtMDJUMTY6NDI6NTEuMTkxOTc0IiwgImZvcmVpZ25faWQiOiBudWxsLCAiaWQiOiAiY2RjOTAyN2MtZTA5NS0xMWU1LTgwODAtODAwMTBkMDJhNzY5IiwgInRvIjogW10sICJvcmlnaW4iOiAidXNlcjo0ODQzIn1dLCAicHVibGlzaGVkX2F0IjogIjIwMTYtMDMtMDJUMTY6NDU6NTAuODM4OTk1KzAwOjAwIiwgImZlZWQiOiAiZmxhdDo0NzY0In1d"

			worker_base = SqsWorkers::WorkerBase.new

			expect(worker_base.decode_base_64(msg)).to eq("[{\"deleted\": [], \"new\": [{\"actor\": \"User:4843\", \"verb\": \"close_quick_idea\", \"object\": \"ResearchedCompany:30092\", \"target\": null, \"time\": \"2016-03-02T16:42:53.615621\", \"foreign_id\": null, \"id\": \"cf3ad432-e095-11e5-8080-8001147c94ce\", \"to\": [], \"origin\": \"user:4843\"}, {\"actor\": \"User:4843\", \"verb\": \"publish_quick_idea\", \"object\": \"ResearchedCompany:30092\", \"target\": null, \"time\": \"2016-03-02T16:42:51.191974\", \"foreign_id\": null, \"id\": \"cdc9027c-e095-11e5-8080-80010d02a769\", \"to\": [], \"origin\": \"user:4843\"}], \"published_at\": \"2016-03-02T16:45:50.838995+00:00\", \"feed\": \"flat:4764\"}]")
		end
	end
end