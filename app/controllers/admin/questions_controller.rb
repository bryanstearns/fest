module Admin
  class QuestionsController < ApplicationController
    before_filter :authenticate_admin!
    respond_to :html

    # GET /admin/questions
    def index
      @show_all = params[:all]
      @questions = @show_all ? Question.all : Question.not_done
      respond_with(:admin, @questions)
    end

    # GET /admin/questions/1
    def show
      respond_with(:admin, @question = Question.find(params[:id]))
    end

    # GET /admin/questions/1/edit
    def edit
      respond_with(:admin, @question = Question.find(params[:id]))
    end

    # PATCH /admin/questions/1
    def update
      @question = Question.find(params[:id])
      if @question.update_attributes(question_params)
        flash[:notice] = 'Question was successfully updated.'
      end
      respond_with(:admin, @question, location: admin_questions_path)
    end

    # DELETE /admin/questions/1
    def destroy
      @question = Question.find(params[:id])
      @question.destroy
      respond_with(:admin, @question, location: admin_questions_path)
    end

  private
    def question_params
      params.require(:question).
              permit(:acknowledged, :done, :email, :name, :question, :user_id)
    end
  end
end
