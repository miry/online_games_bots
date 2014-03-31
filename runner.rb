#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.require

require_relative 'bot/base'
require_relative 'bot/lords_and_knights'
require_relative 'bot/travian'


Capybara.configure do |config|
  # config.asset_root = 'tmp'
  config.save_and_open_page_path = 'tmp'
  config.run_server = false
  # config.current_driver = :webkit
  config.current_driver = :selenium
end

servers = YAML.load_file('config/servers.yml')

servers.each do |name, opts|
  puts ">>> Started bot:#{opts[:bot]} on #{name}"

  bot = case opts[:bot]
        when 'travian'
          bot = Bot::Travian.new opts
        when 'lords_and_kinghts'
          bot = Bot::LordsAndKnights.new opts
        else
          puts 'Could not detect the bot'
          nil
        end


  bot.run
  sleep 10
end
