require "open-uri"

class OpenAiService
  def initialize(sloopy)
    @sloopy = sloopy
  end

  def call
    chatgpt_call
  end

  private

  def chatgpt_call
    client = OpenAI::Client.new
    prompt = build_prompt
    chatgpt_response = client.chat(parameters: {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt}]
      temperature: 0.6
    })
    steps = chatgpt_response[]

  end

  def build_prompt
    <<~PROMPT
      Generate a round-trip itinerary between #{@sloopy.origin} and #{@sloopy.destination} for a trip from #{@sloopy.start_date}, to #{@sloopy.return_date}, with a maximum transport budget of #{@sloopy.budget}.
      The itinerary should include:
      Outbound: Several stops where I can stay a few days (at least 2 stops between #{@sloopy.origin} and #{sloopy.destination}).
      In #{sloopy.destination}: A stay of #{sloopy.duration} full days.
      Return: A different itinerary from the outbound, with at least 1 or 2 new stops where I can stay for one or more nights.
      Return to #{sloopy.origin} on #{sloopy.return_date}.
      Provide the preferred modes of transport (car, bike, bus, train, boat, carpooling) to stay within the budget, and a summary of the costs for each step.
      PROMPT
  end
end
