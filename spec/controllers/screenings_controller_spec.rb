require 'spec_helper'

describe ScreeningsController do
  describe "GET 'show'" do
    it "assigns the requested screening as @screening" do
      screening = create(:screening)
      get :show, {:id => screening.to_param}
      assigns(:screening).should eq(screening)
    end
  end
end
