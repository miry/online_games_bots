module Bot
  class Travian < Bot::Base

    PAGES = {buildings: '/dorf2.php',
             resources: '/dorf1.php',
             building: "/build.php?id=%d",
             hero_adventure: "/hero_adventure.php"
    }

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
        return if upgrade_building(index)
      end

      puts "There are no buildings to upgrade"
      timeout
    end

    def upgrade_building(index)
      choose_building(building_index)
      scope = find("#build #contract")

      return false unless scope.has_selector?("button.build")

      scope.find("button.build").click
      puts ">> Started building: #{find("h1").text} \n#{options[:server]}/#{PAGES[:building] % number}"
      true
    end

    def send_troops_to_missions
      puts "Sending troops to missions"
      choose_page :hero_adventure
      unless has_selector?("td.goTo")
        puts "There are no advantures available"
        return
      end
      first("td.goTo").find("a").click
      click_button ""
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
