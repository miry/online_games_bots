#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'yaml'
require 'json'
require 'logger'

Bundler.require

require 'capybara-screenshot'

require_relative 'bot/base'
require_relative 'bot/lords_and_knights_v2'
require_relative 'bot/lords_and_knights_v3'
require_relative 'bot/travian'

choose_driver = ARGV.first || :chrome_headless
choose_driver = choose_driver.to_sym

logger = Logger.new(STDOUT)
level = ENV['LOG_LEVEL'] || 'INFO'
logger.level = Logger.const_get level.upcase

Selenium::WebDriver.logger.level = 0 if level == 'TRACE'


Capybara.register_driver :chrome_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  chromedriver_opts = {}
  chromedriver_opts = {verbose: true, log_path: '/dev/stdout'} if level == 'TRACE'
  service = Selenium::WebDriver::Chrome::Service.new(args: chromedriver_opts)
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--window-size=1440,1050'
    opts.args << '--disable-gpu'
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
    # NOTICE: Required for containers to not have out of memory crashes
    opts.args << '--disable-dev-shm-usage'
    opts.args << '--verbose' if level == 'TRACE'
    opts.args << '--no-sandbox'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, service: service, options: browser_options)
end

if defined? Capybara::Screenshot
  ::Capybara::Screenshot.register_driver(choose_driver) do |driver, path|
    logger.debug("screenshot path: #{path.inspect}")
    driver.browser.save_screenshot(path)
  end
end

Capybara.current_driver = choose_driver
Capybara.current_session.driver.resize_to(1440, 1050) rescue nil

Capybara.configure do |config|
  # config.asset_root = 'tmp'
  config.save_path = 'tmp'
  config.run_server = false
  config.default_max_wait_time = 10
end

if defined? Capybara::Webkit
  Capybara::Webkit.configure do |config|
    config.debug = true
    config.skip_image_loading
    config.allow_url("lordsandknights.com")
    config.allow_url("*.lordsandknights.com")
    config.block_unknown_urls
    config.block_url("fonts.googleapis.com")
    config.block_url("www.youtube.com")
  end
end

def servers
  if ENV.key?('SERVERS_JSON')
    return JSON.parse(ENV['SERVERS_JSON'])
  elsif File.exists?('config/servers.yml')
    return YAML.load_file('config/servers.yml')
  end
  []
end

servers.each do |name, opts|
  opts = opts.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  opts[:logger] = logger

  logger.info "Started bot #{opts[:bot]} on #{name}"

  Capybara.app_host = opts[:server_url]
  Capybara.default_max_wait_time = opts[:timeout] || 2

  bot_factory = case opts[:bot]
        when 'travian'
          Bot::Travian
        when 'lords_and_kinghts'
          Bot::LordsAndKnights
        when 'lords_and_kinghts_v2'
          Bot::LordsAndKnightsV2
        when 'lords_and_kinghts_v3'
          Bot::LordsAndKnightsV3
        else
          puts 'Could not detect the bot'
          next
        end

  bot = bot_factory.new opts
  bot.run
end
