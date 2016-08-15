module Bot
  class LordsAndKnightsV2 < Bot::Base

    def login
      visit '/'

      play_now_button = find('#header-play-button')
      play_now_button.click

      within 'form#login' do
        fill_in 'loginEmail', with: options[:email]
        fill_in 'loginPassword', with: options[:password]
        find('button').click
      end

      locator = nil
      within '#connected-worlds' do
        locator = find('a', text: options[:server_name]) if options[:server_name]
        locator ||= first('a')
        puts "Chose #{locator.text}"
        locator.click
      end

      find('div.version', text: '4.4.7 / built on: Wed, 13 Apr 2016 09:33:56 +0800')
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

      within ".habitat" do
        find("polygon.#{title}").click
      end
      timeout
    end

    def logout
      find(".Logout").trigger('click')
      find('.win.dialog.frame-container .button', text: 'OK').trigger('click')
    end

    def build_first
      timeout
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

        buildings_range = (options[:buildings] || [])
        p buildings_range
        buildings = {}
        available_buildings = all('.fixedBuildingList .building .button.buildbutton:not(.buildbuttondisabled)')
        available_buildings = all('.fixedBuildingList .building')

        puts "Available buildings:"
        p available_buildings
        p available_buildings.size

        available_buildings.each do |building|
          p building
          p building['class']
          building_name = building.first('.title.buildingName').text
          p building_name
          build_link = building.first('.button.buildbutton') 
          p build_link
          p build_link['class']
          buildings[building_name] = build_link unless build_link['class'].include?('disabled')
        end

        if buildings.empty?
          puts 'There are no buildings to upgrade'
        else
          buildings_range.each do |building_name|
            if buildings.key?(building_name)
              puts "Build #{building_name}"
              buildings[building_name].trigger('click')
              break
            end
          end
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
