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

Capybara.configure do |config|
  # config.asset_root = 'tmp'
  config.save_and_open_page_path = 'tmp'
  config.run_server = false
  config.current_driver = choose_driver.to_sym
  config.default_wait_time = 10
end

if Capybara.current_driver == :selenium
  Capybara.current_session.driver.browser.manage.window.maximize rescue nil
else
  Capybara.current_session.driver.resize_window(1440, 900) rescue nil
  Capybara.current_session.driver.browser.timeout = 1320
  Capybara.current_session.driver.browser.set_skip_image_loading(true)
  Capybara.current_session.driver.header 'User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.74.9 (KHTML, like Gecko) Version/7.0.2 Safari/537.74.9' rescue nil
end

servers = YAML.load_file('config/servers.yml')

servers.each do |name, opts|
  puts ">>> Started bot:#{opts[:bot]} on #{name}"

  Capybara.app_host = opts[:server_url]
  Capybara.default_wait_time = opts[:timeout]

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
