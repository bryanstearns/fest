require 'spec_helper'

describe FestivalsController do
  describe "GET index" do
    it "assigns all festivals as @festivals" do
      festival = create(:festival)
      get :index, {}
      assigns(:festivals).should eq([festival])
    end
  end

  describe "GET show" do
    it "assigns the requested festival as @festival" do
      festival = create(:festival)
      get :show, {:id => festival.to_param}
      assigns(:festival).should eq(festival)
    end
  end
end
