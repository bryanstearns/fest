require 'spec_helper'

describe FestivalsController, type: :controller do
  describe "GET index" do
    it "assigns all festivals as @festivals" do
      festival = create(:festival)
      get :index, {}
      assigns(:festivals).should eq([festival])
    end
  end

  describe "GET show" do
    context "assigns" do
      it "assigns the requested festival as @festival" do
        festival = create(:festival)
        get :show, {:id => festival.to_param}
        assigns(:festival).should eq(festival)
      end
      it "assigns the festival's screenings as @screenings" do
        festival = create(:festival, :with_films_and_screenings)
        get :show, {:id => festival.to_param}
        assigns(:screenings).should eq(festival.screenings)
      end

      it "assigns the current_user's picks as @picks" do
        login_user
        festival = create(:festival)
        picks = double
        Festival.any_instance.stub(:picks_for).and_return(picks)
        get :show, {:id => festival.to_param}
        assigns(:picks).should eq(picks)
      end

      it 'returns a PDF when .pdf format is requested' do
        festival = create(:festival)
        get :show, { id: festival.to_param, format: 'pdf' }
        response.body.should start_with('%PDF-')
      end

      it 'returns an iCalendar when .ics format is requested' do
        festival = create(:festival, :with_films_and_screenings)
        get :show, { id: festival.to_param, format: 'ics' }
        response.body.should start_with('BEGIN:VCALENDAR')
      end

      it 'passes through the debug flag if the user is an admin' do
        user = create(:confirmed_admin_user)
        FestivalsController.any_instance.stub(current_user: user)
        festival = create(:festival)

        get :show, { id: festival.to_param, debug: 'one' }
        assigns(:subscription).debug.should eq('one')
      end
      it 'ignores the debug flag if the user is not an admin' do
        user = create(:confirmed_user)
        FestivalsController.any_instance.stub(current_user: user)
        festival = create(:festival)

        get :show, { id: festival.to_param, debug: 'one' }
        assigns(:subscription).debug.should_not eq('one')
      end
      it 'ignores the debug flag if no user is signed in' do
        festival = create(:festival)

        get :show, { id: festival.to_param, debug: 'one' }
        assigns(:subscription).should be_nil
      end
    end
  end
end
