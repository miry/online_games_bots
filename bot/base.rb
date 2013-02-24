module Bot
  class Base
    include Capybara::DSL

    attr_reader :options

    def initialize(options)
      Capybara.app_host = options[:server]

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
      puts ">> Running actions"

      @actions.each do |action|
        self.send action
      end

      puts "<< Finished"
      run_commands if choose_next_castle
    end

    def choose_first_castle
      true
    end

    def run
      login
      choose_first_castle
      run_commands
      screenshot_and_open_image
      logout
    rescue Capybara::ElementNotFound => e
      puts "FAILED: #{self.class.inspect}"
      screenshot_and_save_page
      puts e
      puts e.backtrace.join("\n")
    end

    def timeout val=nil
      sleep(val || @timeout)
    end

  end
end
