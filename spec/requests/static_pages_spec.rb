require 'spec_helper'

describe "StaticPages" do

  let(:base_title) {"Ruby on Rails Tutorial Sample App"}
  subject {page}

  describe "Home Page" do
    before {visit root_path}

    it {should have_selector('h1', :text => 'Sample App')}
    it {should have_selector('title',
                        text: "Ruby on Rails Tutorial Sample App")}
    it {should_not have_selector('title', 
    		:text => "#{base_title} | Home")}
    
  end

  describe "Help Page" do
    before {visit help_path}
  	it {should have_selector('h1', :text => 'Help')}
  	it {should have_selector('title', 
    		:text => "#{base_title} | Help")}
  end	

  describe "About Page" do
    before {visit about_path}
  	it {should have_content('About Us')}
  	it {should have_selector('title', 
    		:text => "#{base_title} | About Us")}
  end


  describe "Contact page" do
    before {visit contact_path}
    it {should have_selector('h1', text: 'Contact')}
    it {should have_selector('title',
                    text: "Ruby on Rails Tutorial Sample App | Contact")}
  end

  describe "for signed in users" do
    let(:user) {FactoryGirl.create(:user)}
    before do
      FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
      FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
      sign_in user
      visit root_path
    end

    it "should render the user's feed" do
      user.feed.each do |item|
        page.should have_selector("li##{item.id}", text: item.content)
      end
    end

    describe "display stats for follower/following users" do
      let(:other_user){FactoryGirl.create(:user)}
      before do
        other_user.follow!(user)
        visit root_path
      end

      it{should have_link("0 following", href: following_user_path(user))}
      it{should have_link("1 followers", href: followers_user_path(user))}
    end
  end

end
