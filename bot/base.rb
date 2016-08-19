module Bot
  class Base
    MAX_RETRIES = 3
    include Capybara::DSL

    attr_reader :options

    def initialize(options)
      @options = options
      @timeout = options[:timeout] || 5
      @actions = options[:actions] || [:build_first, :send_troops_to_missions]
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
      puts ">> Running actions for selected castle"

      @actions.each do |action|
        self.send action
      end

      puts "<< Finished for selected castle"

      run_commands if choose_next_castle
    end

    def choose_first_castle
      true
    end

    def run
      puts "> Login"
      login
      choose_first_castle
      run_commands
      puts "> Logout"
      logout
    rescue => e
    # rescue Capybara::ElementNotFound => e
      puts "FAILED: #{self.class.inspect}"
      screenshot_and_save_page rescue nil
      puts '--- Eception'
      puts e.class
      puts e.message
      puts e.backtrace.join("\n")
      puts '---- Console'
      p page.driver.console_messages rescue nil
      puts "---- Body"

      #p page.body

      puts '-----'
    end

    def timeout val=nil
      sleep(val || @timeout)
    end

  end
end
