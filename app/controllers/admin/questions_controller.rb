module Admin
  class QuestionsController < ApplicationController
    before_filter :authenticate_admin!
    respond_to :html

    # GET /admin/questions
    def index
      respond_with(:admin, @questions = Question.all)
    end

    # GET /admin/questions/1
    def show
      respond_with(:admin, @question = Question.find(params[:id]))
    end

    # GET /admin/questions/1/edit
    def edit
      respond_with(:admin, @question = Question.find(params[:id]))
    end

    # PUT /admin/questions/1
    def update
      @question = Question.find(params[:id])
      if @question.update_attributes(params[:question])
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
  end
end
