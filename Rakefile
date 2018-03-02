require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'byebug'
require 'rake'
require 'erb'
require 'yaml'
require 'parallel'

raise 'SUT is not set. Please set SUT value' if ENV['SUT'] == nil

raise 'PROFILE is not set. Please set PROFILE value' if ENV['PROFILE'] == nil

PROFILE_TO_RUN = ENV['PROFILE']

task :run_test do
  raise "Profile '#{PROFILE_TO_RUN}' doesn't exist in cucumber yml file. Please check the profile name and run the test again" if check_profile_exists?(PROFILE_TO_RUN) == false
  run_test
end

task :run_test_in_parallel do
  raise "Profile '#{PROFILE_TO_RUN}' doesn't exist in cucumber yml file. Please check the profile name and run the test again" if check_profile_exists?(PROFILE_TO_RUN) == false
  run_tests_in_parallel
end

def check_profile_exists?(profile)
  cucumber_file ||= Dir.glob('{,.config/,config/}cucumber{.yml,.yaml}').first
  cucumber_erb = ERB.new(IO.read(cucumber_file), nil, '%').result(binding)
  YAML::load(cucumber_erb).has_key?(profile)
end


def run_test #looks complex for now. Would simplify as we go along.
  begin
    run_cucumber_tests('first_try', PROFILE_TO_RUN)
  rescue Exception => e
    puts "There is an exception in first_try: #{e} in run_test"
    begin
      run_cucumber_tests('second_time', 'second_try_for_failure_test')
    rescue Exception => e
      puts "There is an exception second_try: #{e} in run_test"
      run_cucumber_tests('third_time', 'third_try_for_failure_test')
    end
  end
end

def run_cucumber_tests(task_name, profile)
  task_to_run = task_name.to_sym
  Cucumber::Rake::Task.new(task_to_run) do |t|
    t.profile = profile
  end
  Rake::Task[task_to_run].invoke
end

def run_tests_in_parallel
  begin
    run_cucumber_tests_in_parallel(PROFILE_TO_RUN) #profile is coming from environment variable
  rescue Exception => e
    puts "There is an exception in first_try: #{e} in run_test"
    begin
      run_cucumber_tests('second_time', 'second_try_for_failure_test')
    rescue Exception => e
      puts "There is an exception second_try: #{e} in run_test"
      run_cucumber_tests('third_time', 'third_try_for_failure_test')
    end
  end
end

def number_of_parallel_tests
  if ENV['parallel'].to_i > 0
    return ENV['parallel']
  else
    return 4
  end
end

def run_cucumber_tests_in_parallel(profile)
  sh "parallel_cucumber features/ -n #{number_of_parallel_tests} -o '-p #{profile}'"
end
