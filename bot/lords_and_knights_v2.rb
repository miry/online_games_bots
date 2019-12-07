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
        logger.info ">>> Chose #{locator.text}"
        locator.click
      end

      find('div.version', text: '4.4.7 / built on: Wed, 13 Apr 2016 09:33:56 +0800')
      timeout
    end

    def choose_page(title)
      within "#gameContainer > .bottombar > .main" do
        link_node = first("a[title=\"#{title}\"]")
        link_node.click if link_node
      end
    end

    def choose_tab(title)
      logger.debug ">>> Choose Tab: #{title}"
      tab_selector = ".habitat .#{title}.tab"
      find(tab_selector).click
      timeout
      has_selector?(tab_selector)
    end

    def choose_building(title)
      choose_tab('visitCastle')

      within ".habitat" do
        find("polygon.#{title}").trigger('click')
      end

      timeout
    end

    def logout
      find(".Logout").trigger('click')
      find('.win.dialog.frame-container .button', text: 'OK').trigger('click')
    end

    def build_first
      timeout
      logger.debug ">> Building first"
      choose_tab('buildingList')
      build_next
      logger.debug "<< Finished Building"
    end

    def build_next
      within '.habitat .buildingList.contentCurrentView' do
        if all(".buildingUpgrade > .building").size > 1
          logger.info "Nothing todo. Workers are busy."
          return
        end

        buildings_range = (options[:buildings] || [])
        buildings = {}
        available_buildings = all('.fixedBuildingList .building')

        available_buildings.each do |building|
          building_name = building.first('.title.buildingName').text
          build_link = building.first('.button.buildbutton')
          break unless build_link
          unless build_link['class'].include?('disabled')
            buildings[building_name] = build_link
          end
        end

        if buildings.empty?
          logger.info 'There are no buildings to upgrade'
          return
        end

        buildings_range.each do |building_name|
          if buildings.key?(building_name)
            logger.info "* Build #{building_name}"
            buildings[building_name].trigger('click')
            break
          end
        end
      end

      timeout
    end

    def choose_first_castle
      unless hasselector?('.win.castleList .content-container .inner-frame .castleHabitatOverview .castleListItem')
        first('.topbar .container .controls > .topbarImageContainer').trigger('click')
        timeout
      end

      if has_selector?('.win.habitat .close')
        first('.win.habitat .close').trigger('click')
      end

      first('.win.castleList .content-container .inner-frame .castleHabitatOverview .castleListItem').trigger('click')

      logger.info ">> Selected castle: #{get_selected_castle}"
      true
    end

    def choose_next_castle
      logger.debug ">> Switch to the next castle"
      # The button appears only in specific order.
      choose_tab('buildingList')
      choose_tab('visitCastle')

      has_selector?("svg.castle-scene-map")

      return false unless has_selector?(".habitat .headerButton.paginate.next")

      find(".habitat .headerButton.paginate.next").trigger('click')
      logger.info ">> Selected castle: #{get_selected_castle}"

      true
    end

    def get_selected_castle
      return find(".habitat .headline > .title").text rescue "--"
    end

    def send_troops_to_missions
      logger.info ">>> Sending troops to missions"
      choose_building 'tavern'

      buttons = all(".missionContainer .missionListItem .button:not(.speedup):not(.disabled)")

      buttons.size.times do |i|
        node = first(".missionContainer .missionListItem .button:not(.speedup):not(.disabled)")
        break if node.nil?
        node.click
        timeout
      end
    end
  end
end
