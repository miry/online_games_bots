module Travian
  class Bot

    PAGES = { buildings: '/dorf2.php',
              resources: '/dorf1.php',
              building: "/build.php?id=%d",
              hero_adventure: "/hero_adventure.php"
    }
    include Capybara::DSL

    attr_reader :options

    def initialize(options)
      Capybara.app_host = options[:server]

      @options = options
      @timeout = options[:timeout] || 5
    end

    def login
      visit "/"

      within "form[name='login']" do
        fill_in "name", with: options[:name]
        fill_in "password", with: options[:password]
        click_button ""
      end

      timeout
    end

    def choose_page(title)
      visit PAGES[title]
    end

    def choose_building(number)
      visit (PAGES[:building] % number)
    end

    def run
      login
      run_commands
      logout
    end

    def logout
      find("#logout").click
    end

    def build_first
      puts "Building first"
      choose_page :resources

      if has_selector?(".boxes.buildingList", visible: true)
        puts "Nothing todo. Workers are busy"
        return
      end

      1.upto(40) do |building_index|

        choose_building(building_index)

        scope = find("#build #contract")

        if scope.has_selector?("button.build")
          scope.find("button.build").click
          puts ">> Started building: #{find("h1").text} \n#{options[:server]}/#{PAGES[:building] % number}"
          return
        end

      end

      puts "There are no buildings to upgrade"
      timeout
    end

    def send_troops_to_missions
      puts "Sending troops to missions"
      choose_page :hero_adventure
      first("td.goTo").find("a").click
      click_button ""
      screenshot_and_open_image
    end

    def run_commands
      puts "Run commands"
      build_first
      send_troops_to_missions
    end

    def timeout val=nil
      sleep(val || @timeout)
    end
  end
end
