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

# Parse options
require 'optparse'

options = {
  config: 'config/servers.yml'
}

OptionParser.new do |opts|
  opts.banner = "Usage: runner.rb [options]"

  opts.on("-cCONFIG", "--config=CONFIG", "Path to servers config. Default: config/servers.yml") do |c|
    options[:config] = c
  end
end.parse!

choose_driver = ARGV.first || :chrome_headless
choose_driver = choose_driver.to_sym

logger = Logger.new(STDOUT)
level = ENV['LOG_LEVEL'] || 'INFO'


logger.level = level == 'TRACE' ? Logger::DEBUG : Logger.const_get(level.upcase)

Selenium::WebDriver.logger.level = 0 if level == 'TRACE'


Capybara.register_driver :chrome_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  chromedriver_opts = {}
  chromedriver_opts = {verbose: true, log_path: '/dev/stderr'} if level == 'TRACE'
  service = Selenium::WebDriver::Chrome::Service.new(args: chromedriver_opts)
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--window-size=1440,1050'
    opts.args << '--disable-gpu'
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
    # NOTICE: Required for containers to not have out of memory crashes
    opts.args << '--disable-dev-shm-usage'
    opts.args << '--no-sandbox'
    if level == 'TRACE'
      opts.args << '--verbose'
      opts.args << '--enable-logging=stderr'
      opts.args << '--v=1'
    end
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
    config.block_url("ssl.gstatic.com")
  end
end

def servers(options)
  if ENV.key?('SERVERS_JSON')
    return JSON.parse(ENV['SERVERS_JSON'], symbolize_names: true)
  elsif File.exists?(options[:config])
    return YAML.load(File.read(options[:config]), symbolize_names: true)
  end
  []
end

connections = servers(options)

if connections.size == 0
  puts "\n\nWARNING No servers provided. Pls check that you have config/servers.yml or SERVERS_JSON environment variable."
  exit 1
end


loop do
  connections.each do |name, opts|
    opts = opts.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    opts[:logger] = logger
    opts[:bot] ||= 'lords_and_kinghts_v3'
    opts[:server_url] ||= 'http://lordsandknights.com'
    opts[:server_url].chop! if opts[:server_url][-1] == '/'
    opts[:loop] = connections.size == 1

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

  if level == 'INFO'
    Dir.foreach('tmp') do |f|
      fn = File.join('tmp', f)
      File.delete(fn) if f != '.' && f != '..'
    end
  end
end