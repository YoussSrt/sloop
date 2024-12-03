class QuestionsController < ApplicationController
  def index
    @questions = current_user.questions
    @question = Question.new # for form
  end

  def create
    @sloopy = Sloopy.find(params[:sloopy_id])
    @questions = current_user.questions # needed in case of validation error
    @question = Question.new(question_params)
    @question.user = current_user
    @question.sloopy = @sloopy


    if params[:sloopy_id].present?
      current_steps = params[:current_steps]&.split(',') || @sloopy.steps.map(&:city)
    else
      current_steps = [] # Aucun itinéraire transmis
    end

    if @question.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(:questions, partial: "questions/question",
            locals: { question: @question })
        end
        format.html { redirect_to questions_path }
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def question_params
    params.require(:question).permit(:user_question)
  end
end
