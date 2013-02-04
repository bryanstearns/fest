class QuestionsController < ApplicationController
  respond_to :html

  # GET /questions/new
  def new
    @question = Question.new
    @question.email = current_user.email if user_signed_in?
    respond_with(@question)
  end

  # POST /questions
  def create
    @question = Question.new(params[:question])
    if @question.save
      flash[:notice] = 'Thanks for contacting me - I\'ll get back to you shortly.'
    end
    respond_with(@question, location: welcome_path)
  end
end
