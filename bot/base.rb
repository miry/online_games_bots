# frozen_string_literal: true

require 'capybara/dsl'

module Bot
  class Base
    MAX_RETRIES = 3
    include Capybara::DSL

    attr_reader :options

    def initialize(options)
      @options = options
      @timeout = options[:timeout] || 5
      @actions = options[:actions] || [:build_first, :send_troops_to_missions]
      @logger  = options[:logger] || Logger.new(STDOUT)
      @first_castle = ""
      @castle = ""
      @enable_loop = options[:loop]
    end

    def login
      raise NotImplementedError
    end

    def logout
      raise NotImplementedError
    end

    def build_first
      raise NotImplementedError
    end

    def events
      raise NotImplementedError
    end

    def send_troops_to_missions
      raise NotImplementedError
    end

    def choose_next_castle
      false
    end

    def run_commands
      @actions.each do |action|
        if action.is_a?(Hash)
          action.each do |action_name, action_options|
            next if action_options.key?(:enable) && action_options[:enable] != true
            self.send(action_name, action_options)
          end
        else
          self.send action
        end
      end
    end

    def choose_first_castle
      true
    end

    def run
      login

      loop do
        choose_first_castle
        run_commands

        while choose_next_castle
          run_commands
          timeout
        end

        break if @enable_loop == false
        timeout
      end

      logger.info "> Logout"
      logger.info " "
    rescue => e
    # rescue Capybara::ElementNotFound => e
      logger.info "FAILED: #{self.class.inspect}"
      screenshot_and_save_page rescue nil
      logger.debug '--- Exception'
      logger.debug e.class
      logger.info e.message
      logger.debug e.backtrace.join("\n")
      logger.debug '---- Console'
      logger.debug(page.driver.console_messages) rescue nil
      logger.debug "---- Body"
      # logger.debug page.body
      logger.debug '-----'
    end

    def timeout val=nil
      sleep(val || @timeout)
    end

    def wait_until(selector, retries=MAX_RETRIES, **options)
      logger.debug "   * wait_until #{selector}"
      while retries > 0 && !has_selector?(selector, options)
        timeout
        retries -= 1
      end
    end

    def wait_while(selector, retries=MAX_RETRIES, **options)
      logger.debug "   * wait_while #{selector}"
      while retries > 0 && has_selector?(selector, options)
        timeout
        retries -= 1
      end
    end

    def logger
      @logger
    end

    def first_castle?
      @castle == @first_castle
    end
  end
end
