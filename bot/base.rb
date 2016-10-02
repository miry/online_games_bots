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

    def send_troops_to_missions
      raise NotImplementedError
    end

    def choose_next_castle
      false
    end

    def run_commands
      logger.debug ">> Running actions for selected castle"

      @actions.each do |action|
        self.send action
      end

      logger.debug "<< Finished for selected castle"

      run_commands if choose_next_castle

      if @enable_loop
        logger.debug "!!! Started from the First Castle"
        run_commands if choose_first_castle
      end
    end

    def choose_first_castle
      true
    end

    def run
      logger.debug "> Login"
      login
      choose_first_castle
      run_commands
      logger.debug "> Logout"
      logout
    rescue => e
    # rescue Capybara::ElementNotFound => e
      logger.debug "FAILED: #{self.class.inspect}"
      screenshot_and_save_page rescue nil
      logger.debug '--- Eception'
      logger.debug e.class
      logger.debug e.message
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

    def logger
      @logger
    end

  end
end
