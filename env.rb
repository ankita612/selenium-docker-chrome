require 'capybara/cucumber'
require 'selenium/webdriver'
require 'capybara/rspec'
require 'capybara-screenshot'
require 'capybara/angular'
require 'capybara/angular/waiter'
require 'active_support/inflector' #for underscore/camelize/dasherize methods
require 'faker'
require 'mail'
require 'httparty'
require 'json'
require 'net/http'
require 'chronic'
require 'date'
require 'byebug'
require 'informix'
require 'rest-client'



DEFAULT_MAX_WAIT_TIME = 30
use_browser = ENV['BROWSER']

#cleaning the existing reports.

FileUtils.rm_rf("reports")
FileUtils.mkdir_p("reports/junit")
FileUtils.mkdir_p("reports/json")
FileUtils.mkdir_p("reports/html")

puts 'Created necessary test report directories'

raise 'Unknown system under test please set the SUT value' if ENV['SUT'] == nil

class TestEnvironmentSettings
  attr_accessor :env_sut #sut - system under test

  def initialize
    self.env_sut=ENV['SUT'].upcase
  end
end

World { TestEnvironmentSettings.new }

module BeginSession

  def setup_base_url

    case env_sut #accessor from TestEnvironmentSettings class

      when 'LIVE'
        @root_url = '{live_url}'
      when 'TEST'
        @root_url = '{test_url}'

      else
        raise 'Unknown system under test please set the SUT value'
    end

  end

end

World(BeginSession)

Capybara.default_driver = :selenium

Capybara.register_driver :selenium do |app|

  case use_browser

    when 'chrome_headless'
      args = ['--enable-popup-blocking', '--enable-external-protocol-request', '--disable-extensions',
              '--headless', '--disable-gpu', '--no-sandbox', '--window-size=1280,800', '--verbose',
              '--disable-impl-side-painting', '--ignore-certificate-errors', '--incognito']
      caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => args})
      Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          url: "http://localhost:4444/wd/hub",
          desired_capabilities: caps)

    when 'chrome'
      caps = Selenium::WebDriver::Remote::Capabilities.chrome
      Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          url: "http://localhost:4444/wd/hub",
          desired_capabilities: caps)
    else
      raise 'Unidentified BROWSER. Please set which browser to use. e.g. BROWSER=firefox or chrome or ie'
  end
end

if RUBY_PLATFORM.to_s.include?('linux') == false #this to safe guard that the linux boxes are not disturbed
  ENV['HTTP_PROXY'] = nil
end

$browser = Capybara.current_session.driver.browser #this would give you the access to the driver instance
$browser.manage.window.resize_to(1680, 1050)
Capybara.default_max_wait_time = DEFAULT_MAX_WAIT_TIME
Capybara.default_selector = :css