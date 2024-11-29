require 'open-uri'
require 'json'


class OpenAiService
  def initialize(sloopy)
    @sloopy = sloopy
  end

  def call
    chatgpt_call
    parse_itinerary(chatgpt_call)
  end

  def parse_itinerary(response_text)
    response_text.gsub!('`', '')
    response_text.gsub!('json', '')
    hash = JSON.parse(response_text)

    # Création de steps
    @sloopy.update(summary: hash["summary"])
    hash["steps"].each do |step|
      step["details"].each do |detail|
        new_step = Step.create(
          sloopy: @sloopy,
          city: detail["city"],
          city_stop: detail["city"].split('to')[-1].strip,
          transport: detail["transport"],
          cost: detail["cost"],
          duration: detail["duration"]
        )

          detail["activities"].each do |activity|
            new_activity = Activity.new(
              name: activity["name"],
              address: activity["address"]
            )
            new_activity.step = new_step
            new_activity.save
          end
      end
    end
  end

  private

  def chatgpt_call
    client = OpenAI::Client.new
    prompt = build_prompt
    chatgpt_response = client.chat(parameters: {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt}],
      temperature: 0.7
    })
    return chatgpt_response["choices"][0]["message"]["content"]
  end

  def build_prompt
    <<~PROMPT
      Generate two round-trip itinerary between #{@sloopy.origin} and #{@sloopy.destination} for a trip from #{@sloopy.departure_date}, with a maximum transport budget of #{@sloopy.budget}€.
      The itinerary should include:
      Outbound: Several stops where I can stay a few days (at least 2 stops between #{@sloopy.origin} and #{@sloopy.destination}) and do several activities (with the adresses) in relation with my tastes: #{@sloopy.user.formatted_preferences}.
      In #{@sloopy.destination}: A stay of #{@sloopy.duration} full days.
      Return: A different itinerary from the outbound, with at least 1 or 2 new stops where I can stay for one or more nights.
      Return to #{@sloopy.origin} on #{@sloopy.return_date}.
      Provide the preferred modes of transport (car, bike, bus, train, boat, carpooling but no plane) to stay within the budget, and a summary of the costs for each step.
      Do a short resume for each itinerary as a description.
      Without any of your own answer like 'Here is a round-trip itinerary'.
      Can you serialize the data with a Hash wich looks like this:
      {
        "summary": "This itinerary allows for a rich exploration of various cities while enjoying a week in Rome, all while staying within the transport budget.",
        "steps": [
          {
            "route": "Outbound Itinerary: Berlin to Rome",
            "period": "2025-09-25 to 2025-10-02",
            "details": [
              {
                "city": "Berlin to Nuremberg",
                "transport": "Train (DB)",
                "cost": "€50",
                "duration": "3.5 hours",
                "activities": [
                  { "name": "Visit the Nuremberg Castle", "address": "Burg 13, 90403 Nuremberg" },
                  { "name": "Explore the Documentation Center Nazi Party Rally Grounds", "address": "Bayernstraße 110, 90478 Nuremberg" }
                ],
                "stay": "2 nights"
              },
              # Les autres étapes suivent la même structure
            ]
          },
          {
            "route": "Return Itinerary: Rome to Berlin",
            "period": "2025-10-02 to 2025-10-09",
            "details": [
              {
                "city": "Rome to Florence",
                "transport": "Train (Italo or Trenitalia)",
                "cost": "€30",
                "duration": "1.5 hours",
                "activities": [
                  { "name": "Visit the Uffizi Gallery", "address": "Piazzale degli Uffizi, 6, 50122 Firenze" },
                  { "name": "Explore the Florence Cathedral", "address": "Piazza del Duomo, 50122 Firenze" }
                ],
                "stay": "2 nights"
              },
              # Les autres étapes suivent la même structure
            ]
          }
        ],
        "budget": {
          "outbound": "€240",
          "return": "€270",
          "overall": "€510",
          "grand_total": "€672"
        }
      }
      PROMPT
  end

end
