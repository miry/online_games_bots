# frozen_string_literal: true

module Bot
  class LordsAndKnightsV3 < Bot::Base

    def initialize(options)
      super
      @actions = options[:actions] || [:build_first, :research, :send_troops_to_missions, :events]
      @build_list = building_list
      logger.debug "Building List:"
      logger.debug(@build_list || "Any available")
    end

    def events
      logger.info ">> Events"
      choose_bottom_menu_item("Events")
      timeout

      within '#menu-section-general-container .menu--content-section' do
        selector = '.menu-list-element.menu-list-element-basic.clickable.with-icon-right:not(.color-red)'
        if has_selector?(selector)
          button = all(selector)[0]
          logger.info "* Collect the prize for the event #{button.text()}"
          button.click
        end
      end

      wait_until('#game-pop-up-layer', visible: true)
      popup_close
      wait_until('#game-pop-up-layer', visible: false)
    end

    def login
      visit '/'

      if has_selector?('.form--data--logout')
        first('.form--data--logout').click
      end

      logger.debug("Fill login information: #{options[:email]}")
      wait_until('form.form--login', 30)
      within 'form.form--login' do
        fill_in 'login-name', with: options[:email]
        fill_in 'login-password', with: options[:password]
        find('button').click
      end

      logger.info("Choose the server: #{options[:server_name]}")
      within '#choose-world-scene' do
        locator = nil
        locator = first('div.button-game-world--title', text: options[:server_name]) if options[:server_name]
        locator ||= first('div.button-game-world--title')
        locator.click
      end

      logger.debug("Waiting when page is ready")
      wait_while('.loading-spinner.loading-spinner--pending', 10)
      wait_until('canvas#game-canvas', 10)
      find('canvas#game-canvas', text: 'Browser strategy game Lords and Knights')
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

    def choose_building(titles)
      titles = [titles] unless titles.is_a?(Array)
      logger.debug(": choose_building #{titles.join(', ')}")
      result = nil
      available_buildings = all('#menu-section-general-container > .menu-section > .menu--content-section .menu-list-element.menu-list-element-basic.clickable.with-icon-left.with-icon-right')
      available_buildings.each do |building|
        building_name = building.first('.menu-list-element-basic--title').text()
        next unless titles.include?(building_name)
        result = building
        building.click()
        timeout
        break
      end
      result
    end

    def choose_building_list
      logger.debug(": choose_building_list")
      return if has_selector?('div.top-bar-button--HabitatBuildings.active')
      first('div.top-bar-button--HabitatBuildings').click()
    end

    def choose_tavern
      choose_building_list
      choose_building(["Tavern", "Tavern Quarter"])
    end

    def choose_library
      choose_building_list
      choose_building("Library")
    end

    def choose_university
      choose_building_list
      choose_building(["Library", "University", "University area"])
    end

    def research
      logger.info ">> Research"
      return unless choose_university

      return if has_selector?('#menu-section-drill-container .menu--content-section > div:last-child .icon-research-finish')

      within('#menu-section-drill-container .menu--content-section > div:last-child') do
        buttons = all('button:not(.disabled)')
        buttons.each do |button|
          next if button.has_selector?('div.icon-research-speedup') || button.has_selector?('div.icon-research-finish')
          button.click
          timeout
        end
      end
    end

    def logout
      find(".Logout").trigger('click')
      find('.win.dialog.frame-container .button', text: 'OK').trigger('click')
    end

    def build_first
      logger.info ">> Building"
      choose_building_list
      build_next
      logger.debug "<< Finished Building"
    end

    def build_next
      within '#menu-section-general-container > .menu-section > .menu--content-section' do
        current_buildings = all('.widget--upgrades-in-progress--list > .menu-list-element.with-icon-right')
        if current_buildings.size > 0
          # Check if there is Free build
          first_building = current_buildings.first
          if first_building.find('button .icon')[:class].include?('icon-build-finish-free')
            first_building_title = first_building.find('.menu-list-element-basic--title').text()
            logger.info "Finish Free speedup #{first_building_title}"
            first_building.find(:button).click
            return if current_buildings.size > 1
          else
            logger.info "Nothing todo. Workers are busy."
            return
          end
        end

        buildings = get_available_buildings

        if buildings.empty?
          logger.info 'There are no buildings to upgrade'
          return
        end

        # If there are no buildings to build, build all available
        buildings_range = @build_list || buildings.keys.map {|b| {name: b}}.reverse

        buildings_range.each do |building_name|
          name = building_name
          level = nil
          if building_name.is_a?(Hash)
            name = building_name[:name]
            level = building_name[:level]
          end
          logger.debug("Check if #{name} with level #{level} available")
          if buildings.key?(name) && (level.nil? || level > buildings[name][:level])
            logger.info "* Upgrade #{name} with level #{buildings[name][:level]}"
            buildings[name][:button].click()
            break
          end
        end
      end

      timeout
    end

    def choose_first_castle
      popup_close
      logger.debug(": choose_first_castle")
      # Enabled by default
      # choose_building_list
      logger.info "> Selected castle: #{get_selected_castle}"
      true
    end

    def choose_next_castle
      logger.debug ": choose_next_castle"

      locator = all(".habitat-chooser--title-row .arrow-right")[0]
      if locator
        locator.click()
        timeout(1)
      end

      logger.info "> Selected castle: #{get_selected_castle}"
      true
    end

    def choose_bottom_menu_item(title)
      logger.debug(": choose_bottom_menu_item #{title}")
      result = nil
      available_buildings = all('#game-bar-bottom .bar-bottom--content--gaming .bar-bottom--content--gaming-item')
      available_buildings.each do |building|
        menu_title = building.first('.button-for-bars--title').text()
        next unless menu_title == title
        result = building
        building.click() unless building.has_selector?(".button-for-bars.active")

        break
      end
      timeout
      result
    end

    def get_selected_castle
      logger.debug(": get_selected_castle")
      locator = first(".habitat-chooser .habitat-chooser--title span")
      return locator.text rescue "--"
    end

    def send_troops_to_missions
      logger.info ">> Sending troops to missions"
      choose_tavern

      within('#menu-section-drill-container .menu--content-section > div:last-child') do
        buttons = all('button:not(.disabled)')
        buttons.each do |button|
          next unless button.has_selector?('div.icon-mission')
          button.click
          timeout
        end
      end
    end

    def send_troops_from_all_castles
      logger.info ">> Send troops from all castles"
      choose_bottom_menu_item("Mass functions")
      timeout
      choose_building("Carry out mission")
      timeout
      wait_while("#over-layer--game-pending")

      # select_all_castles
      button = find('#menu-section-drill-container .menu--content-section > div:first-child')
      if button.text != "Deselect all castles"
        button.click
        timeout
        # check if no mission selected
        button = find('#menu-section-drill-container .menu--content-section > div:first-child')
      end

      # select_all_fortresses
      button = find('#menu-section-drill-container .menu--content-section > div:nth-child(2)')
      if button.text != "Deselect all fortresses"
        button.click
        timeout
        # check if no mission selected
        button = find('#menu-section-drill-container .menu--content-section > div:nth-child(2)')
      end

      # carry_out_mission
      button = find('#menu-section-drill-container .menu--content-section > div.last .menu-list-element-basic--title')
      count = find('#menu-section-drill-container .menu--content-section > div.last .menu-list-element-basic--value')
      if count && count.text.to_i > 0
        logger.debug "Click on #{button.text} with #{count.text} missions"
        button.click
        timeout
      end
    end

    def popup_close
      return false if all('#game-pop-up-layer', visible: true).size == 0
      logger.info "Popup is open"

      selectors = [
        "#game-pop-up-layer .event-pop-up-button.ButtonRedAccept",
        "#game-pop-up-layer .event-pop-up-button.Back",
      ]

      selectors.each do |selector|
        locator = all(selector)[0]
        if locator
          locator.click
          timeout
          return popup_close
        end
      end

      return false
    end

    def get_available_buildings
      buildings = {}
      available_buildings = []
      if has_selector?('.widget--upgrades-in-progress--list')
        upgrade_section = first('.widget--upgrades-in-progress--list')
        available_buildings = all('.widget--upgrades-in-progress--list + .menu-list-element.menu-list-element-basic.clickable.with-icon-left.with-icon-right:not(.disabled)')
      else
        available_buildings = all('.menu-list-element.menu-list-element-basic.clickable.with-icon-left.with-icon-right:not(.disabled)')
      end

      # Available: button button--default button-with-icon  menu-element--button--action button--action button--in-building-list--construct-tavern
      # All finished: There are no button element
      # Not enough resources: button button--default button-with-icon disabled  menu-element--button--action button--action button--in-building-list--construct-lumberjack
      available_buildings.each do |building|
        building_name = building.first('.menu-list-element-basic--title').text()
        building_description = ""
        if building.has_selector?('.menu-list-element-basic--description')
          building_description = building.first('.menu-list-element-basic--description').text()
        end
        building_level = 0
        if building_description.include?("Upgrade level ")
          building_level = building_description[14..].to_i
        end

        # Skip building when there are no upgrades
        next unless building.has_selector?('button')

        build_button = building.first('button')

        # Skip building when there are not enough resources
        next if build_button['class'].include?('disabled')

        # Add to building list
        buildings[building_name] = {button: build_button, level: building_level, name: building_name, description: building_description}
      end
      buildings
    end

    def building_list
      buildings_range = options[:buildings]
      return nil if buildings_range.nil?

      buildings_range.flat_map do |building_name|
        case building_name
        when Hash
          building_name.keys.map do |name|
            building_name[name].merge({name: name.to_s})
          end
        else
          {level: nil, name: building_name.to_s}
        end
      end
    end
  end
end
