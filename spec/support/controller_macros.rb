module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @signed_in_user = FactoryGirl.create(:confirmed_admin_user)
      sign_in @signed_in_user
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @signed_in_user = FactoryGirl.create(:confirmed_user)
      sign_in @signed_in_user
    end
  end

  def logged_out
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @signed_in_user = nil
      sign_out :user
    end
  end
end
