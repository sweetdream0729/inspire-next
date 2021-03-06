require 'spec_helper'

feature 'UI/Messages' do
  background do
    @user = create(:user)
    @channel = create(:channel,user:@user,tparty_keyword:Faker::Lorem.word)
    @ind_channel = create(:individually_scheduled_messages_channel,user:@user)
    sign_in_using_form(@user)
    within navigation_selector do
      click_link 'Channels'
    end
  end

  context 'are listed on the channel\'s page' do
    background do
      @simple_message1 = create(:message,channel:@channel)
      @simple_message2 = create(:message,title:'',channel:@channel)
      @messages = [@simple_message1,@simple_message2]
      within "tr#channel_#{@channel.id}" do
        click_link @channel.name
      end
    end
    scenario "title is shown if present(mms) or caption otherwise" do
      within *div_id_selector('message-list') do
        expect(page).to have_content(@simple_message1.caption[0..10])
        expect(page).to have_content(@simple_message2.caption[0..10])
      end
    end
  end

  context 'in the #new page' do
    background do
      within "tr#channel_#{@channel.id}" do
        click_link @channel.name
      end
      within *div_id_selector('message-list') do
        find(*a_id_selector('message-new')).click
      end
    end
    scenario 'allows setting of title, caption, attachment and type' do
      expect(page).to     have_css "select#message_type"
      expect(page).not_to have_css "select#message_type.read_only"
      expect(page).to     have_css "textarea#message_caption"
      expect(page).to     have_css "input#message_content"
    end

    scenario 'does not allow setting schedule for channels which do not allow it' do
      expect(page).not_to have_css "input#message_next_send_time"
    end
  end
  context 'in the new page for channels which allow individual message scheduling' do
    background do
      within "tr#channel_#{@ind_channel.id}" do
        click_link @ind_channel.name
      end
      within *div_id_selector('message-list') do
        find(*a_id_selector('message-new')).click
      end
    end
    scenario 'allows setting schedule' do
      expect(page).to have_css "input#message_next_send_time"
    end
  end

  context 'in the edit page' do
    background do
      @message = create(:message,channel:@channel)
      within "tr#channel_#{@channel.id}" do
        click_link @channel.name
      end
      within "div#message-list" do
        within "tr#message_#{@message.id}" do
          click_link 'Edit'
        end
      end
    end
    scenario 'has title caption and content and readonly message type ' do
      expect(page).to have_css "select#message_type.readonly"
      expect(page).to have_css "textarea#message_caption"
      expect(page).to have_css "input#message_content"
    end
  end
end
