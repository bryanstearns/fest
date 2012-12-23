require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe FestivalsController do

  # This should return the minimal set of attributes required to create a valid
  # Festival. As you add validations to Festival, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    attributes_for(:festival)
  end

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

  describe "GET new" do
    login_admin
    it "assigns a new festival as @festival" do
      get :new, {}
      assigns(:festival).should be_a_new(Festival)
    end
  end

  describe "GET edit" do
    login_admin
    it "assigns the requested festival as @festival" do
      festival = create(:festival)
      get :edit, {:id => festival.to_param}
      assigns(:festival).should eq(festival)
    end
  end

  describe "POST create" do
    login_admin
    describe "with valid params" do
      it "creates a new Festival" do
        expect {
          post :create, {:festival => valid_attributes}
        }.to change(Festival, :count).by(1)
      end

      it "assigns a newly created festival as @festival" do
        post :create, {:festival => valid_attributes}
        assigns(:festival).should be_a(Festival)
        assigns(:festival).should be_persisted
      end

      it "redirects to the created festival" do
        post :create, {:festival => valid_attributes}
        response.should redirect_to(Festival.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved festival as @festival" do
        # Trigger the behavior that occurs when invalid params are submitted
        Festival.any_instance.stub(:save).and_return(false)
        post :create, {:festival => {}}
        assigns(:festival).should be_a_new(Festival)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Festival.any_instance.stub(:save).and_return(false)
        Festival.any_instance.stub(:errors).and_return(some: ['errors'])
        post :create, {:festival => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    login_admin
    describe "with valid params" do
      it "updates the requested festival" do
        festival = create(:festival)
        # Assuming there are no other festivals in the database, this
        # specifies that the Festival created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Festival.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => festival.to_param, :festival => {'these' => 'params'}}
      end

      it "assigns the requested festival as @festival" do
        festival = create(:festival)
        put :update, {:id => festival.to_param, :festival => valid_attributes}
        assigns(:festival).should eq(festival)
      end

      it "redirects to the festival" do
        festival = create(:festival)
        put :update, {:id => festival.to_param, :festival => valid_attributes}
        response.should redirect_to(festival)
      end
    end

    describe "with invalid params" do
      it "assigns the festival as @festival" do
        festival = create(:festival)
        # Trigger the behavior that occurs when invalid params are submitted
        Festival.any_instance.stub(:save).and_return(false)
        put :update, {:id => festival.to_param, :festival => {}}
        assigns(:festival).should eq(festival)
      end

      it "re-renders the 'edit' template" do
        festival = create(:festival)
        # Trigger the behavior that occurs when invalid params are submitted
        Festival.any_instance.stub(:save).and_return(false)
        Festival.any_instance.stub(:errors).and_return(some: ['errors'])
        put :update, {:id => festival.to_param, :festival => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    login_admin
    it "destroys the requested festival" do
      festival = create(:festival)
      expect {
        delete :destroy, {:id => festival.to_param}
      }.to change(Festival, :count).by(-1)
    end

    it "redirects to the festivals list" do
      festival = create(:festival)
      delete :destroy, {:id => festival.to_param}
      response.should redirect_to(festivals_url)
    end
  end
end
