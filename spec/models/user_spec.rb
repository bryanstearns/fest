require 'spec_helper'

describe User do
  it "should create a new user given valid attributes" do
    User.create!(attributes_for(:user))
  end
end
