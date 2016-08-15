#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.require

require_relative 'bot/base'
require_relative 'bot/lords_and_knights'
require_relative 'bot/lords_and_knights_v2'
require_relative 'bot/travian'

choose_driver = ARGV.first || :webkit

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.configure do |config|
  # config.asset_root = 'tmp'
  config.save_path = 'tmp'
  config.run_server = false
  config.current_driver = choose_driver.to_sym
  config.default_max_wait_time = 10
end

Capybara::Webkit.configure do |config|
  config.debug = true
  config.skip_image_loading
  config.allow_url("lordsandknights.com")
  config.allow_url("*.lordsandknights.com")
  config.block_unknown_urls
  config.block_url("fonts.googleapis.com")
  config.block_url("www.youtube.com")
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {js_errors: false})
end

if Capybara.current_driver == :selenium
  Capybara.current_session.driver.browser.manage.window.maximize rescue nil
else
  Capybara.current_session.driver.resize_to(1440, 1050) rescue nil
#  Capybara.current_session.driver.browser.timeout = 1320
#  Capybara.current_session.driver.browser.set_skip_image_loading(true)
  Capybara.current_session.driver.header 'User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2828.0 Safari/537.36' rescue nil
end

servers = YAML.load_file('config/servers.yml')

servers.each do |name, opts|
  puts ">>> Started bot:#{opts[:bot]} on #{name}"

  Capybara.app_host = opts[:server_url]
  Capybara.default_max_wait_time = opts[:timeout] || 2

  bot_factory = case opts[:bot]
        when 'travian'
          Bot::Travian
        when 'lords_and_kinghts'
          Bot::LordsAndKnights
        when 'lords_and_kinghts_v2'
          Bot::LordsAndKnightsV2
        else
          puts 'Could not detect the bot'
          next
        end

  bot = bot_factory.new opts
  bot.run
  sleep 10
end
