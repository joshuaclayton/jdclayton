desc "Shortcut for functional tests"
task :f => "test:functionals"

desc "Shortcut for unit tests"
task :u => "test:units"

desc "Shortcut for integration tests"
task :i => "test:integration"

desc "Run all types of tests, but stop on failure"
task :t => ["test:units", "test:functionals", "test:integration"]