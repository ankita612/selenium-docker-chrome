**Docker container running parallel test for Ruby Cucumber using Selenium Grid** 


This container uses the docker container from SeleniumHQ the main repository is at https://github.com/SeleniumHQ/docker-selenium

**Running locally**

`./entrypoint.sh %%PROFILE%% %%BROWSER%% %%SUT%%`

Here: 
replace %%PROFILE%% with the cucumber.yml prodile that you would like to run 
replace %%BROWSER%% with the browser name from env.rb that you would like to run test on
replace %%SUT%% with the environment (test, stage or production) from env.rb that you would like to run test on


**Running on Bamboo**

Here in the script Task on bamboo:
`rbenv install 2.3.1 -s; rbenv local 2.3.1 #this is to tell bamboo what ruby version you would like to rubn ur test ON

 gem install bundler #install bundler

 bundle install #it would install the bundle as per ruby version selected

 ruby -v #ensure you have correct version of ruby on docker before you run the test

 ./entrypoint.sh %%PROFILE%% %%BROWSER%% %%SUT%%`
 
 
 
**Chrome Browser configuration on env.rb file to run with docker** 
 
 `url = 'http://localhost:4444/wd/hub'
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
  
  Capybara.register_driver :selenium_grid_remote_browser do |app|
    Capybara::Selenium::Driver.new(app, :browser => :remote, :url => url, :desired_capabilities => capabilities )
  end
  
  Capybara.default_driver = :selenium_grid_remote_browser`
  
**Chrome Headless Browser configuration on env.rb file to run with docker** 
   
   `url = 'http://localhost:4444/wd/hub' 
   
   args = ['--enable-popup-blocking', '--enable-external-protocol-request', '--disable-extensions',
                  '--headless', '--disable-gpu', '--no-sandbox', '--window-size=1280,800', '--verbose',
                  '--disable-impl-side-painting', '--ignore-certificate-errors', '--incognito']
   
   capabilities = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => args})
   
   Capybara.register_driver :selenium_grid_remote_browser do |app|
    Capybara::Selenium::Driver.new(app, :browser => :remote, :url => url, :desired_capabilities => capabilities)
   end 
   
   Capybara.default_driver = :selenium_grid_remote_browser`