class ChatbotJob < ApplicationJob
  queue_as :default

  def perform(question, sloopy)
    @question = question
    @sloopy = sloopy
    chatgpt_response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: questions_formatted_for_openai, # to code as private method
        temperature: 0.5
      }
    )
    new_content = chatgpt_response["choices"][0]["message"]["content"]

    question.update(ai_answer: new_content)
    Turbo::StreamsChannel.broadcast_update_to(
      "question_#{@question.id}",
      target: "question_#{@question.id}",
      partial: "questions/question", locals: { question: question })
  end

  def update_steps(chat_response, sloopy)
    chat_response = @sloopy.questions.last.ai_answer.split(/:\s*\n\n(?<data>{.*})/)[1]

    chat_answer = eval(chat_response)
    chat_answer["steps"].each do |step|
      @sloopy.steps.update!(
        city: step["city"],
        transport: step["transport"],
        cost: step["cost"],
        duration: step["duration"],
        activities: step["activities"].map do |activity|
          Activity.new(name: activity["name"], address: activity["address"])
        end
      )
    end
  end

  private

  def client
    @client ||= OpenAI::Client.new
  end

  def questions_formatted_for_openai
    questions = @question.user.questions
    results = []
    results << { role: "system", content: "You are an assistant for a travel itinerary generation website. The user is planning a trip and has already created an itinerary. Which is this one #{@sloopy}, here are all the steps #{@sloopy.steps} and their activities, answer considering all the informations serialized here #{@sloopy.serialize_sloopy}, like the time, the price etc... answer with just the data, no fantasy words'." }
    questions.each do |question|
      results << { role: "user", content: question.user_question }
      results << { role: "assistant", content: question.ai_answer || "" }
    end
    return results
  end


end
