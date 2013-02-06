module Bot
  class LordsAndKnights < Bot::Base

    def login
      visit "/"
      click_link "openLoginButton"

      within "form#loginForm" do
        fill_in "loginEmail", with: options[:email]
        fill_in "loginPassword", with: options[:password]
        find("#loginbutton").click()
      end

      timeout

      locator = nil
      if options[:server_id]
        locator = all("#worldswithlogin .worldlink").select{|i| i[:class] =~ /{worldId: '#{options[:server_id]}'}/}.first
      end
      locator ||= first("#worldswithlogin .worldlink")
      puts "Chose #{locator.text}"
      locator.click
      timeout
    end

    def choose_page(title)
      within "#gameContainer > .bottombar > .main" do
        link_node = first("a[title=\"#{title}\"]")
        if link_node && !link_node[:class].include?("active")
          link_node.click
        end
      end
    end

    def choose_building(title)
      within "div#habitatView" do
        find("a.#{title}").click
      end
      timeout
    end

    def logout
      find("#logmeout").click
    end

    def build_first
      puts "Building first"
      choose_page "Castle"
      timeout 

      if all("#buildinglist > table:first-child .building").size > 0
        puts "Nothing todo. Workers are busy"
        return
      end

      within "#buildinglist > table:last-child" do
        building = first(".upgradebutton:last-child")
        if building
          building.click 
        else
          puts "There are buildings to upgrade"
        end
      end

      timeout
    end

    def send_troops_to_missions
      puts "Sending troops to missions"
      choose_building 'tavern'

      all("div.div_checkbox_missions input").each do |node|
        node.set(true)
      end

      find("#btn_missions_start").click()
      timeout
    end

    def run_commands
      puts "Run commands"
      timeout(10)
      build_first
      send_troops_to_missions
    end
  end
end
