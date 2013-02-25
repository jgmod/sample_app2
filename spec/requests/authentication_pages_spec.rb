require 'spec_helper'

describe "AuthenticationPages" do
	subject { page }

  	describe "signin page" do
    	before { visit signin_path }

	    it { should have_selector('h1',    text: 'Sign in') }
    	it { should have_selector('title', text: 'Sign in') }
	end

	describe "Authentication" do
		let(:user) {FactoryGirl.create(:user)}
		before {sign_in(user)}

		describe 'with valid information' do
			it {should have_selector('title', text: user.name)}
			it {should have_link('Users', href: users_path)}
			it {should have_link('Profile', href: user_path(user))}
			it {should have_link('Settings', href: edit_user_path(user))}
			it {should have_link('Sign out', href: signout_path)}
			it {should_not have_link('Sign in', href: signin_path)}
		end
	end

	describe "Authorization" do
		let(:user) {FactoryGirl.create(:user)}

		describe "as wrong user" do
			let(:user){FactoryGirl.create(:user)}
			let(:wrong_user){FactoryGirl.create(:user, email:"wrong@example.com")}
			before {sign_in user}

			describe "visiting users#edit page" do
				before {visit edit_user_path(wrong_user)}
				it {should_not have_selector('title', text: full_title('Edit user'))}	
			end	

			describe "submitting a put request to the Users#update action" do
				before {put user_path(wrong_user)}
				specify {response.should redirect_to(root_path)}
			end
		end

		describe "for non-signed in users" do
			
			describe "in the users controller" do
				describe "visiting the edit page" do
					before {visit edit_user_path(user)}
					it {should have_selector('title', text:"Sign in")}
				end
				describe "submitting to the update action" do
					before {put user_path(user)}
					specify {response.should redirect_to(signin_path)}
				end
			end


			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(user)
					fill_in "Email", with: user.email
					fill_in "Password", with: user.password
					click_button "Sign in"
				end

			
				describe "after signing in" do
					it "should render the desired protected page" do
						page.should have_selector('title', text: "Edit user")
					end
				end
			end
		end

		describe "for non-admin users" do
			let(:user){FactoryGirl.create(:user)}
			let(:non_admin){FactoryGirl.create(:user)}

			before {sign_in non_admin}

			describe "submitting a DELETE request to Users#destroy action" do
				before {delete user_path(user)}
				specify {response.should redirect_to(root_path)}
			end
		end

		describe "for admin user" do
			let(:admin){FactoryGirl.create(:admin)}

			before {sign_in admin}

			describe "submitting a DELETE request to delete admin" do
				before {delete user_path(admin)}
				specify {response.should redirect_to(user_path(admin))}
			end
		end

		describe "in the Micoposts controller" do
			describe "submitting to the create action" do
				before {post microposts_path}
				specify {response.should redirect_to(signin_path)}
			end

			describe "submitting to the destroy action " do
				before {delete micropost_path(FactoryGirl.create(:micropost))}
				specify {response.should redirect_to(signin_path)}
			end
		end
	end

end