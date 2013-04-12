require! {
	"buster-test"
	"buster-assertions"
	"buster-sinon"
}

module.exports = class BusterMinimal implements buster-test
	assertions:buster-assertions

	add-case: (name,tests)->
		@cases.push @test-case name,tests

		return this

	run: ->
		runner = buster-test.test-runner.create!
		runner.assertion-count = ~> @count

		runner.on \suite:end (results)->
			process.next-tick ->
				process.exit results.errors + results.timeouts + results.failures

		reporter = @reporters.(@config.reporter).create @config.reporter-options
		reporter.listen runner

		runner.run-suite @cases

		return this

	(config = {})->
		@cases = []
		@count = 0
		@config = {reporter: process.env.BUSTER_REPORTER ? \dots, reporter-options: {+color}} import config

		@test-runner.on-create (runner)~>
			runner.on \test:start ~> @count = 0
			runner.on \test:setUp ~> @assertions.throw-on-failure = on

		@assertions.on \pass ~>@count++
		@assertions.on \failure ~>@count++