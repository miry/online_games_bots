module Bot
  class Base
    include Capybara::DSL

    attr_reader :options

    def initialize(options)
      Capybara.app_host = options[:server]

      @options = options
      @timeout = options[:timeout] || 5
    end

    def login
      raise NotImplementedError
    end

    def logout
      raise NotImplementedError
    end

    def run_commands

    end

    def run
      login
      run_commands
      logout
    end

    def timeout val=nil
      sleep(val || @timeout)
    end

  end
end