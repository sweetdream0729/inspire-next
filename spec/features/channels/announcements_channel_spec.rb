require 'spec_helper'

feature 'Announcements Channel' do
  background do
    @user = create(:user)
    sign_in_using_form(@user)  
  end
  context "creation", :js=>true do
    background do
      within "div#top-menu" do
        click_link 'Channels'
      end
      within "div#channels-section" do
        click_link 'New'
      end      
      select 'Announcements channel', from:'channel_type'            
    end
    scenario "is possible from the new form" do
      name = Faker::Lorem.words(2).join(' ')
      fill_in "Name", with:name
      fill_in "channel_tparty_keyword", with:'+14084084080'
      click_button "Create Channel"
      expect(page).to have_title(name.titleize)
    end
    scenario "does not allow schedule to be set" do
      page.should_not have_css("select#channel_schedule")      
    end
  end

  context "show" do
    background do
      @channel = create(:announcements_channel, user:@user)
      @messages = (0..2).map{create(:message, channel:@channel)}
      within "div#top-menu" do
        click_link 'Channels'
      end         
      within "div#channels-section" do
        click_link @channel.name
      end
    end
    scenario "has button to trigger message broadcast" do
      within("div#message-list tr#message_#{@messages[1].id}") do
        expect(page).to have_link('Broadcast')
      end
    end  
      
    scenario "does not list the up and down button alongside messages" do
      @messages.each do |message|
        within("div#message-list tr#message_#{message.id}") do
          expect(page).to_not have_link('Up')
          expect(page).to_not have_link('Down')
        end
      end
    end

    scenario "the default sort order of messages is reverse chronological" do
      within_table 'messages_table' do
        rows = all('tr')
        rows[1].should have_content(@messages[2].title)
        rows[2].should have_content(@messages[1].title)
        rows[3].should have_content(@messages[0].title)
      end
    end  
  end
end
