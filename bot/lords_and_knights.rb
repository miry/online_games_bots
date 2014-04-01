module Bot
  class LordsAndKnights < Bot::Base

    def login
      visit '/'

      within 'form#login' do
        fill_in 'loginEmail', with: options[:email]
        fill_in 'loginPassword', with: options[:password]
        click_on 'Play Now'
      end

      timeout
      screenshot_and_save_page

      find('#world-selection')
      find('label', text: 'Use old version').click

      screenshot_and_save_page

      locator = nil
      within '#connected-worlds' do
        locator = find('a', text: options[:server_name]) if options[:server_name]
        locator ||= first('a')
        puts "Chose #{locator.text}"
        locator.click
      end

      timeout
      screenshot_and_save_page
      find('#gameContainer')
    end

    def choose_page(title)
      within "#gameContainer > .bottombar > .main" do
        link_node = first("a[title=\"#{title}\"]")
        link_node.click if link_node
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
      puts ">> Building first"
      choose_page "Castle"
      timeout

      build_next

      puts "<< Finished Building"
    end

    def build_next
      if all("#buildinglist > table").size > 1
        puts "Nothing todo. Workers are busy"
        return
      end

      within "#buildinglist > table:last-child" do

        buildings_range = options[:buildings] || (13..1)

        buildings_selector = buildings_range.map { |b| "table:nth-child(#{b}) .upgradebutton" }.join(",")
        building = all(buildings_selector).first
        if building
          building.click
        else
          puts "There are buildings to upgrade"
        end
      end

      timeout
    end

    def choose_next_castle
      return false if has_selector?("#nextHabitat.disabled")

      find("#nextHabitat").click
      puts ">>> Selected castle: #{get_selected_castle}"

      true
    end

    def get_selected_castle
      within ".navigation" do
        return find(".habitatesSelect #btn_hab_name").text rescue "--"
      end
    end

    def send_troops_to_missions
      puts ">>> Sending troops to missions"
      choose_building 'tavern'

      all("div.div_checkbox_missions input").each do |node|
        node.set(true)
      end

      find("#btn_missions_start").click()
      timeout
    end
  end
end
