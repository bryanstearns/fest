module ControllerMacros
  extend ActiveSupport::Concern

  def login_admin
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @signed_in_user = FactoryBot.create(:confirmed_admin_user)
    sign_in @signed_in_user
  end

  def login_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @signed_in_user = FactoryBot.create(:confirmed_user)
    sign_in @signed_in_user
  end

  def logged_out
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @signed_in_user = nil
    sign_out :user
  end

  module ClassMethods
    def login_admin
      before(:each) do
        login_admin
      end
    end

    def login_user
      before(:each) do
        login_user
      end
    end
    def logged_out
      before(:each) do
        logged_out
      end
    end
  end
end
