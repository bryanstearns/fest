require 'spec_helper'

describe PicksController do
  login_user

  describe "GET index" do
    it "assigns the festival's films as @films" do
      festival = create(:festival, :with_films)
      get :index, { :festival_id => festival.to_param }
      assigns(:films).should eq(festival.films.by_name)
    end
  end

  describe "POST create" do
    let(:festival) { create(:festival, :with_films) }
    let(:film_id) { festival.films.first.to_param }
    let(:post_params) { { :film_id => film_id,
                          :pick => { :priority => "2" },
                          :attribute => 'priority' } }
    subject { post :create, post_params.merge(format: :js) }

    it "requires an authenticated user" do
      logged_out
      subject
      response.response_code.should == 401
    end

    describe "for a user who'd not previously saved a pick for that film" do
      describe "with valid params" do
        it "creates a new Pick" do
          expect { subject }.to change(Pick, :count).by(1)
        end

        it "responds with :created status" do
          subject
          response.response_code.should == 201
        end
      end
      describe "with invalid params" do
        let(:post_params) { { :film_id => film_id,
                              :pick => { :rating => "arf" },
                              :attribute => 'rating' } }
        it "does not create a new pick" do
          expect { subject }.to change(Pick, :count).by(0)
        end
        it "responds with :unprocessable_entity status" do
          subject
          response.response_code.should == 422
        end
      end
      describe "with valid but default params" do
        let(:post_params) { { :film_id => film_id,
                              :pick => { :rating => nil },
                              :attribute => 'rating' } }
        it "does not create a new pick" do
          expect { subject }.to change(Pick, :count).by(0)
        end
        it "responds with :created status" do
          subject
          response.response_code.should == 201
        end
      end
    end

    describe "for a user who'd previously saved a pick for that film" do
      before(:each) do
        @pick = controller.current_user.picks.create!({ festival: festival,
                                                        priority: 1,
                                                        film_id: film_id },
                                                      as: :pick_creator)
      end

      describe "with valid params" do
        let(:post_params) { { :film_id => film_id,
                              :pick => { :priority => "2" },
                              :attribute => 'priority' } }
        it "updates the existing Pick" do
          Pick.any_instance.should_receive(:update_attributes)\
                           .with("priority" => "2")
          subject
        end

        it "responds with success status" do
          subject
          response.response_code.should == 201
        end
      end
      describe "with invalid params" do
        let(:post_params) { { :film_id => film_id,
                              :pick => { :rating => "ishtar" },
                              :attribute => 'rating' } }
        it "responds with unprocessable_entity status" do
          subject
          response.response_code.should == 422
        end
      end
    end
  end
end
