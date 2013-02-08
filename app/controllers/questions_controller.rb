class QuestionsController < ApplicationController
  respond_to :html

  # GET /questions/new
  def new
    @question = Question.new
    if user_signed_in?
      @question.name = current_user.name
      @question.email = current_user.email
    end
    respond_with(@question)
  end

  # POST /questions
  def create
    @question = Question.new(params[:question])
    if @question.save
      flash[:notice] = 'Thanks for contacting me - I\'ll get back to you shortly.'
      Mailer.feedback(@question).deliver
    end
    respond_with(@question, location: welcome_path)
  end
end
