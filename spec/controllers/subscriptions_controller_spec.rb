require 'spec_helper'

describe SubscriptionsController do
  let(:festival) { create(:festival, :with_films_and_screenings) }

  describe "GET show" do
    describe "when there's no user signed in" do
      logged_out
      it "builds a dummy subscription" do
        expect { get :show, { :festival_id => festival.id } }.to \
          change(Subscription, :count).by(0)
        assigns(:subscription).should be_new_record
      end
    end

    describe "when there's a signed-in user" do
      login_user

      describe "who has a subscription for this festival already" do
        let!(:subscription) { create(:subscription,
                                     festival: festival,
                                     user: @signed_in_user,
                                     show_press: false) }

        it "loads the existing subscription" do
          expect { get :show, { :festival_id => festival.id } }.to \
            change(Subscription, :count).by(0)
          assigns(:subscription).should eq(subscription)
        end
      end

      describe "who has no subscription for this festival" do
        it "creates a subscription" do
          expect { get :show, { :festival_id => festival.id } }.to \
            change(Subscription, :count).by(1)
          assigns(:subscription).should_not be_new_record
        end
      end
    end
  end

  describe "PUT update" do
    it "requires an authenticated user" do
      put :update, {:festival_id => festival.id,
                    :subscription => { "show_press" => true } }
      response.should redirect_to(new_user_session_path)
    end

    describe "with a signed-in user" do
      login_user

      describe "with valid params" do
        let!(:subscription) { create(:subscription,
                                     festival: festival,
                                     user: @signed_in_user,
                                     show_press: false) }

        it "updates the requested subscription" do
          Subscription.any_instance.should_receive(:update_attributes)\
            .with({ "show_press" => true })
          put :update, {:festival_id => festival.id,
                        :subscription => { "show_press" => true } }
        end

        it "assigns the requested subscription as @subscription" do
          put :update, { :festival_id => festival.id,
                         :subscription => { "show_press" => false} }
          assigns(:subscription).should eq(subscription)
        end

        it "redirects to the festival" do
          put :update, { :festival_id => festival.id,
                         :subscription => { "show_press" => false} }
          response.should redirect_to(festival_path(subscription.festival))
        end
      end

      #No invalid params yet...
      #describe "with invalid params" do
      #  it "assigns the subscription as @subscription" do
      #    subscription = Subscription.create! valid_attributes
      #    # Trigger the behavior that occurs when invalid params are submitted
      #    Subscription.any_instance.stub(:save).and_return(false)
      #    put :update, {:id => subscription.to_param, :subscription => { "festival_id" => "invalid value" }}, valid_session
      #    assigns(:subscription).should eq(subscription)
      #  end
      #
      #  it "re-renders the 'show' template" do
      #    subscription = Subscription.create! valid_attributes
      #    # Trigger the behavior that occurs when invalid params are submitted
      #    Subscription.any_instance.stub(:save).and_return(false)
      #    put :update, {:id => subscription.to_param, :subscription => { "festival_id" => "invalid value" }}, valid_session
      #    response.should render_template("show")
      #  end
      #end
    end
  end
end
