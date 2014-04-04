module Bot
  class LordsAndKnights < Bot::Base

    def login
      visit '/game-login/'

      within 'form#login' do
        fill_in 'loginEmail', with: options[:email]
        fill_in 'loginPassword', with: options[:password]
        click_on 'Login'
      end

      find('#world-selection')
      find('label', text: 'Use old version').click

      locator = nil
      within '#connected-worlds' do
        locator = find('a', text: options[:server_name]) if options[:server_name]
        locator ||= first('a')
        puts "Chose #{locator.text}"
        timeout
        locator.click
      end

      timeout

      find('#gameContainer')
      find('#gameVersion', text: '1.8.8')
    rescue Capybara::ElementNotFound => e
      @tries ||= 0

      if @tries < Bot::Base::MAX_RETRIES
        @tries += 1
        timeout(@timeout*@tries)
        retry
      end
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

        buildings = options[:buildings] || ['Lumberjack']

        buildings.each do |building_title|
          building_node = find('.habitatListItemText', text: building_title, visible: false)
          row_node = building_node.first(:xpath, ".//ancestor::td[1]")
          button_node = row_node.first('.upgradebutton')
          p button_node
          if button_node
            p button_node['class']
            button_node.click
            puts "- #{building_title}"
            break
          end
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

      all("div.div_checkbox_missions").each do |node|
        begin
          check_box = node.find('input', visible: true)
          if check_box
            prev_node = node.first(:xpath, ".//preceding-sibling::*[1]")
            puts "- #{prev_node.text}"

            check_box.set(true)
          end
        rescue Capybara::ElementNotFound => e
          p e.class
        end
      end

      find("#btn_missions_start").click()
      timeout
    end
  end
end
