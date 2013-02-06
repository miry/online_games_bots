#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.require

require_relative 'lords_and_knights/bot'

Capybara.current_driver = :webkit
Capybara.app_host = 'http://www.lordsandknights.com'

servers = YAML.load_file('config/servers.yml')

servers.each do |name, opts|
  bot = case opts[:bot]
        when 'travian'
          bot = Travian::Bot.new opts
        when 'lords_and_kinghts'
          bot = LordsAndKnights::Bot.new opts
        else
          puts "Could not detect the bot"
        end

  bot.run
  sleep 10
end
