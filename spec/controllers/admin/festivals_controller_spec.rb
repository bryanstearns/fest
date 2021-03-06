require 'rails_helper'

describe Admin::FestivalsController, type: :controller do
  login_admin

  # This should return the minimal set of attributes required to create a valid
  # Festival. As you add validations to Festival, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    attributes_for(:festival)
  end

  describe "GET show" do
    it "assigns the requested festival as @festival" do
      festival = create(:festival)
      get :show, params: {:id => festival.to_param}
      assigns(:festival).should eq(festival)
    end
  end

  describe "GET new" do
    it "assigns a new festival as @festival" do
      get :new, params: {}
      assigns(:festival).should be_a_new(Festival)
    end
  end

  describe "GET edit" do
    it "assigns the requested festival as @festival" do
      festival = create(:festival)
      get :edit, params: {:id => festival.to_param}
      assigns(:festival).should eq(festival)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Festival" do
        expect {
          post :create, params: {:festival => valid_attributes}
        }.to change(Festival, :count).by(1)
      end

      it "assigns a newly created festival as @festival" do
        post :create, params: {:festival => valid_attributes}
        assigns(:festival).should be_a(Festival)
        assigns(:festival).should be_persisted
      end

      it "redirects to the festivals page" do
        post :create, params: {:festival => valid_attributes}
        response.should redirect_to(festivals_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved festival as @festival" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Festival).to receive(:save).and_return(false)
        post :create, params: {:festival => { name: '' }}
        assigns(:festival).should be_a_new(Festival)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Festival).to receive(:save).and_return(false)
        allow_any_instance_of(Festival).to receive(:errors).and_return(some: ['errors'])
        post :create, params: {:festival => { name: '' }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested festival" do
        festival = create(:festival)
        # Assuming there are no other festivals in the database, this
        # specifies that the Festival created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Festival).
          to receive(:update_attributes).
          with(PermittedParams.new('name' => 'bogus'))
        put :update, params: {:id => festival.to_param, :festival => {'name' => 'bogus'}}
      end

      it "assigns the requested festival as @festival" do
        festival = create(:festival)
        put :update, params: {:id => festival.to_param,
                      :festival => valid_attributes}
        assigns(:festival).should eq(festival.reload)
      end

      it "redirects to the festival" do
        festival = create(:festival)
        put :update, params: {:id => festival.to_param,
                      :festival => valid_attributes}
        response.should redirect_to(festival.reload)
      end
    end

    describe "with invalid params" do
      it "assigns the festival as @festival" do
        festival = create(:festival)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Festival).to receive(:save).and_return(false)
        put :update, params: {:id => festival.to_param, :festival => { name: '' }}
        assigns(:festival).should eq(festival)
      end

      it "re-renders the 'edit' template" do
        festival = create(:festival)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Festival).to receive(:save).and_return(false)
        allow_any_instance_of(Festival).to receive(:errors).and_return(some: ['errors'])
        put :update, params: {:id => festival.to_param, :festival => { name: '' }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested festival" do
      festival = create(:festival)
      expect {
        delete :destroy, params: {:id => festival.to_param}
      }.to change(Festival, :count).by(-1)
    end

    it "redirects to the festivals list" do
      festival = create(:festival)
      delete :destroy, params: {:id => festival.to_param}
      response.should redirect_to(festivals_url)
    end
  end
end
