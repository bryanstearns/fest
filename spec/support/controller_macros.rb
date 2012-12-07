module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:confirmed_admin_user)
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:confirmed_user)
      sign_in user
    end
  end

  def logged_out
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_out :user
    end
  end
end
