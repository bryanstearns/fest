require 'rails_helper'

describe SubscriptionsController, type: :controller do
  let(:festival) { create(:festival, :with_films_and_screenings) }

  describe "GET show" do
    describe "when there's no user signed in" do
      logged_out
      it "builds a dummy subscription" do
        expect { get :show, params: { :festival_id => festival.to_param } }.to \
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
          expect { get :show, params: { :festival_id => festival.to_param } }.to \
            change(Subscription, :count).by(0)
          assigns(:subscription).should eq(subscription)
        end
      end

      describe "who has no subscription for this festival" do
        it "creates a subscription" do
          expect { get :show, params: { :festival_id => festival.to_param } }.to \
            change(Subscription, :count).by(1)
          assigns(:subscription).should_not be_new_record
        end
      end
    end
  end

  describe "PUT update" do
    it "requires an authenticated user" do
      put :update, params: {:festival_id => festival.to_param,
                    :subscription => { show_press: true },
                                       skip_autoscheduler: true }
      response.should redirect_to(new_user_session_path)
    end

    describe "with a signed-in user" do
      login_user

      describe "with valid params" do
        let!(:subscription) { create(:subscription,
                                     festival: festival,
                                     user: @signed_in_user,
                                     show_press: false) }

        it 'updates the requested subscription' do
          allow_any_instance_of(Subscription).to receive(:update_attributes).
            with(PermittedParams.new('show_press' => "true",
                  'skip_autoscheduler' => "true"))
          put :update, params: {:festival_id => festival.to_param,
                        :subscription => { 'show_press' => true,
                                           'skip_autoscheduler' => true } }
        end

        it 'assigns the requested subscription as @subscription' do
          put :update, params: { :festival_id => festival.to_param,
                         :subscription => { 'show_press' => false,
                                            'skip_autoscheduler' => true } }
          assigns(:subscription).should eq(subscription)
        end

        it 'tries to run the autoscheduler' do
          allow_any_instance_of(AutoScheduler).to receive(:should_run?).and_return(true)
          expect_any_instance_of(AutoScheduler).to receive(:run).and_return(nil)
          put :update, params: { :festival_id => festival.to_param,
                         :subscription => { 'debug' => nil } }
        end

        it 'redirects to the festival' do
          put :update, params: { :festival_id => festival.to_param,
                         :subscription => { 'show_press' => false,
                                            'skip_autoscheduler' => true } }
          response.should redirect_to(festival_path(subscription.festival))
        end

        it 'redirects with the debug flag if the user is an admin' do
          put :update, params: { :festival_id => festival.to_param,
                         :subscription => { 'show_press' => false,
                                            'skip_autoscheduler' => true,
                                            'debug' => 'one' } }
          response.should redirect_to(festival_path(subscription.festival,
                                                    'debug' => 'one'))
        end
      end

      describe "with invalid params" do
        let!(:subscription) { create(:subscription, user: @signed_in_user,
                                     festival: festival) }
        it "assigns the subscription as @subscription" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Subscription).to receive(:save).and_return(false)
          allow_any_instance_of(Subscription).to receive(:errors).and_return(some: ['errors'])
          put :update, params: { :festival_id => festival.to_param,
                         :subscription => { "restriction_text" => "invalid value" }}
          assigns(:subscription).should eq(subscription)
        end

        it "re-renders the 'show' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Subscription).to receive(:save).and_return(false)
          allow_any_instance_of(Subscription).to receive(:errors).and_return(some: ['errors'])
          put :update, params: { :festival_id => festival.to_param,
                         :subscription => { "restriction_text" => "invalid value" }}
          response.should render_template("show")
        end
      end
    end
  end
end
