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
      puts ">> Building first"
      choose_page :resources

      if has_selector?(".boxes.buildingList", visible: true)
        puts "Nothing todo. Workers are busy"
        return
      end

      buildings_range = options[:buildings] || (1..18)
      buildings_range.each do |building_index|
        return if upgrade_building(building_index)
      end

      puts "There are no buildings to upgrade"
      timeout
    end

    def upgrade_building(building_index)
      choose_building(building_index)

      return false unless has_selector?("#build #contract")
      scope = find("#build #contract")

      return false unless scope.has_selector?("button.build")

      title = first("h1").text

      scope.find("button.build").click

      puts ">> Started building: #{title} \n#{options[:server]}/#{PAGES[:building] % building_index}"
      true
    rescue Capybara::ElementNotFound => e
      puts "ERROR: Find bug in action upgrade_building"
      screenshot_and_save_page
      puts e.backtrace.join("\n")
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

    def choose_first_castle
      return false unless has_selector?("#villageListLinks")
      first("#villageListLinks li.entry > a").click
      puts ">>> Selected castle: #{get_selected_castle}"

      true
    end

    def choose_next_castle

      return false unless has_selector?("#villageListLinks li.entry.active + li.entry")
      first("#villageListLinks li.entry.active + li.entry > a").click
      puts ">>> Selected castle: #{get_selected_castle}"

      true
    end

    def timeout val=nil
      sleep(val || @timeout)
    end

    def get_selected_castle
      find("#villageNameField").text rescue "--"
    end
  end
end
