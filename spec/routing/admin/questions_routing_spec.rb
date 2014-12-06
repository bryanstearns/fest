require "spec_helper"

describe Admin::QuestionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      get("/admin/questions").should route_to("admin/questions#index")
    end

    it "routes to #show" do
      get("/admin/questions/1").should route_to("admin/questions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/questions/1/edit").should route_to("admin/questions#edit", :id => "1")
    end

    it "routes to #update" do
      put("/admin/questions/1").should route_to("admin/questions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/questions/1").should route_to("admin/questions#destroy", :id => "1")
    end
  end
end
