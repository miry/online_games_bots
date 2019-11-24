# frozen_string_literal: true

module Bot
  class LordsAndKnightsV3 < Bot::Base

    def login
      visit '/'
      timeout
      logger.info(">>> Fill login information")
      within 'form.form--login' do
        fill_in 'login-name', with: options[:email]
        fill_in 'login-password', with: options[:password]
        find('button').click
      end

      logger.info(">>> Choose the server")
      locator = nil
      within '#choose-world-scene' do
        locator = first('div.button-game-world--title', text: options[:server_name]) if options[:server_name]
        locator ||= first('div.button-game-world--title')
        locator.click
      end

      logger.info(">>> Waiting when page is ready")
      timeout
      find('canvas#game-canvas', text: 'Browser strategy game Lords and Knights')
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

    def choose_building_list
      return if has_selector?('.menu--content-section')
      first('div.top-bar-button--HabitatBuildings').click()
    end

    def logout
      find(".Logout").trigger('click')
      find('.win.dialog.frame-container .button', text: 'OK').trigger('click')
    end

    def build_first
      logger.debug ">> Building first"
      choose_building_list
      build_next
      logger.debug "<< Finished Building"
    end

    def build_next
      within '.menu--content-section' do
        current_buildings = all('.widget--upgrades-in-progress--list > .menu-list-element.with-icon-right')
        if current_buildings.size > 0
          logger.info "Nothing todo. Workers are busy."
          return
        end

        buildings_range = (options[:buildings] || [])
        buildings = {}
        available_buildings = all('.menu-list-element.menu-list-element-basic.clickable.with-icon-left.with-icon-right')

        available_buildings.each do |building|
          building_name = building.first('.menu-list-element-basic--title').text()
          build_button = building.first('button')
          #break unless build_link
          buildings[building_name] = build_button
        end

        if buildings.empty?
          logger.info 'There are no buildings to upgrade'
          return
        end

        buildings_range.each do |building_name|
          logger.debug("Check if #{building_name} available")
          if buildings.key?(building_name)
            logger.info "* Build #{building_name}"
            buildings[building_name].click()
            break
          end
        end
      end

      timeout
    end

    def choose_first_castle
      logger.debug(": choose_first_castle")
      # Enabled by default
      # choose_building_list
      logger.info ">> Selected castle: #{get_selected_castle}"
      true
    end

    def choose_next_castle
      logger.debug ">> Switch to the next castle"

      locator = first(".habitat-chooser--title-row .arrow-right")
      locator.click()
      logger.debug("Locator: #{locator}")
      logger.info ">> Selected castle: #{get_selected_castle}"

      true
    end

    def get_selected_castle
      logger.debug(": get_selected_castle")
      locator = first(".habitat-chooser .habitat-chooser--title span")
      return locator.text rescue "--"
    end

    def send_troops_to_missions
      return true
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
