require 'rails_helper'

describe QuestionsController, type: :controller do
  def valid_attributes
    attributes_for(:question)
  end

  describe "GET new" do
    it "assigns a new question as @question" do
      get :new, {}
      assigns(:question).should be_a_new(Question)
    end
    context "with a logged-in user" do
      login_user
      it "should set the user's name email automatically" do
        get :new, {}
        assigns(:question).email.should == @signed_in_user.email
        assigns(:question).name.should == @signed_in_user.name
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Question" do
        expect {
          post :create, {:question => valid_attributes}
        }.to change(Question, :count).by(1)
      end

      it "assigns a newly created question as @question" do
        post :create, {:question => valid_attributes}
        assigns(:question).should be_a(Question)
        assigns(:question).should be_persisted
      end

      it "redirects to the home page" do
        post :create, {:question => valid_attributes}
        response.should redirect_to(welcome_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved question as @question" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Question).to receive(:save).and_return(false)
        allow_any_instance_of(Question).to receive(:errors).and_return(some: ['errors'])
        post :create, {:question => { "email" => "" }}
        assigns(:question).should be_a_new(Question)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Question).to receive(:save).and_return(false)
        allow_any_instance_of(Question).to receive(:errors).and_return(some: ['errors'])
        post :create, {:question => { "email" => "" }}
        response.should render_template("new")
      end
    end
  end
end
