module Bot
  class LordsAndKnightsV2 < Bot::Base

    def login
      visit '/'

      within 'form#login' do
        fill_in 'loginEmail', with: options[:email]
        fill_in 'loginPassword', with: options[:password]
        click_on 'Play Now'
      end

      locator = nil
      within '#connected-worlds' do
        locator = find('a', text: options[:server_name]) if options[:server_name]
        locator ||= first('a')
        puts "Chose #{locator.text}"
        locator.click
      end

      find('div.version', text: '2.0.8 / build on: Tue, 21 Jan 2014 16:49:24 +0100')
    end

    def choose_page(title)
      within "#gameContainer > .bottombar > .main" do
        link_node = first("a[title=\"#{title}\"]")
        link_node.click if link_node
      end
    end

    def choose_tab(title)
      find(".habitat .#{title}.tab").click()
    end

    def choose_building(title)
      choose_tab('visitCastle')
      timeout

      within ".habitat .habitatView.contentCurrentView" do
        find("a.#{title}").click
      end
      timeout
    end

    def logout
      find(".Logout").click
      find('.win.dialog.frame-container .button', text: 'OK').click
    end

    def build_first
      puts ">> Building first"

      choose_tab('buildingList')
      timeout

      build_next
      puts "<< Finished Building"
    end

    def build_next
      # if all("#buildinglist > table").size > 1
      #   puts "Nothing todo. Workers are busy"
      #   return
      # end

      within '.habitat .buildingList.contentCurrentView' do

        buildings_range = options[:buildings].map(&:to_i) || (12..0)
        buildings = []
        available_buildings = all('.fixedBuildingList > .building .button.buildbutton')

        buildings_range.each do |i|
          building = available_buildings[i]
          buildings << building unless building['class'].include?('disabled')
        end

        if buildings.empty?
          puts 'There are no buildings to upgrade'
        else
          buildings.first.click
        end
      end

      timeout
    end

    def choose_next_castle
      return false
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

      all(".missionContainer .missionListItem .button").each do |node|
        node.click() unless node['class'].include?('speedup')
      end
    end
  end
end
