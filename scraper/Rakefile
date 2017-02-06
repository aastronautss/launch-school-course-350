require_relative "./db"

desc "Setup project"
task :setup do
  Database.create_tables
end

desc "Open a console"
task :console do
  require "irb"
  ARGV.clear
  IRB.start
end
