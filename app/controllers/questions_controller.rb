class QuestionsController < ApplicationController
  def show
    question = Question.find_by(id: params[:id])

    if question
      render json: { answer: question.answer }
    else
      render json: { error: "This question doesn't exist" }, status: :not_found
    end
  end
end
