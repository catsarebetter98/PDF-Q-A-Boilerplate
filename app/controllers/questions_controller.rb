require 'daru'

class QuestionsController < ApplicationController
  def show
    question = Question.find_by(id: params[:id])

    if question
      render json: { question: question.question, answer: question.answer }
    else
      render json: { error: "This question doesn't exist" }, status: :not_found
    end
  end

  def ask
    question_asked = params[:question]

    if !question_asked.ends_with?('?')
      question_asked += '?'
    end

    previous_question = Question.find_by(question: question_asked)

    if previous_question
      puts "previously asked and answered: #{previous_question.answer}"
      previous_question.ask_count += 1
      previous_question.save
      render json: { question: previous_question.question, answer: previous_question.answer, id: previous_question.id }
    else
      df = Daru::DataFrame.from_csv('book.pdf.pages.csv')
      document_embeddings = QuestionService.load_embeddings('book.pdf.embeddings.csv')
      answer, context = QuestionService.answer_query_with_context(question_asked, df, document_embeddings)

      project_uuid = '6314e4df'

      question = Question.new(question: question_asked, answer: answer, context: context, ask_count: 0)
      question.save

      render json: { question: question.question, answer: answer, id: question.id }
    end
  end  
end
