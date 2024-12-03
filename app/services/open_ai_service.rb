require 'open-uri'
require 'json'


class OpenAiService
  def initialize(sloopy, formatted_preferences, current_index)
    @sloopy = sloopy
    @formatted_preferences = formatted_preferences
    @current_index = current_index
  end

  def call
    chatgpt_call
    parse_itinerary(chatgpt_call)
  end

  def parse_itinerary(response_text)
    response_text.gsub!('`', '')
    response_text.gsub!('json', '')
    sloopies = JSON.parse(response_text)
    first_travel = sloopies["itineraries"][0]
    # Création de steps
    @sloopy.update(summary: first_travel["summary"], budget_estimated: first_travel["budget"]["overall"])

    first_travel["steps"].each do |step|
      step["details"].each do |detail|
        new_step = Step.create(
          sloopy: @sloopy,
          city: detail["city"],
          city_stop: detail["city"].split('to')[-1].strip,
          transport: detail["transport"],
          cost: detail["cost"],
          duration: detail["duration"],
          stays: detail["stay"]
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

    Turbo::StreamsChannel.broadcast_replace_to(
      "sloopy_#{@sloopy.id}",
      target: "sloopy_#{@sloopy.id}",
      partial: "sloopies/sloopy",
      locals: { sloopy: @sloopy, index: @current_index - 1 }
    )

  end

  private

  def chatgpt_call
    client = OpenAI::Client.new
    prompt = build_prompt
    chatgpt_response = client.chat(parameters: {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt}],
      temperature: 0.8
    })
    return chatgpt_response["choices"][0]["message"]["content"]
  end

  def build_prompt
    <<~PROMPT
      Generate one distinct round-trip itineraries between #{@sloopy.origin} and #{@sloopy.destination} for a trip from #{@sloopy.departure_date}, with a maximum transport budget of #{@sloopy.budget}€.
      The itinerary should include:
      Outbound: Several stops where I can stay a few days (At least 3 stops logically located between #{@sloopy.origin} and #{@sloopy.destination} (e.g., cities or towns geographically aligned on a plausible route)) and do several activities (with the adresses) in relation with my tastes: #{@formatted_preferences}.
      In #{@sloopy.destination}: A stay of #{@sloopy.duration} full days and very important, with a list of daily activities (with addresses) that match my tastes: #{@formatted_preferences}.
      Return: A different itinerary from the outbound, with at least 2 or 3 new stops where I can stay for one or more nights.
      Return to #{@sloopy.origin} on #{@sloopy.return_date}.
      Provide the preferred modes of transport (car, bike, bus, train, boat, carpooling but no plane) to stay within the budget, and a summary of the costs for each step.
      Write a short and unique summary for each itinerary, highlighting its distinct experiences, the charm of the stops, and the overall travel vibe to make it feel exciting and personalized.
      Without any of your own answer like 'Here is a round-trip itinerary'.
      Stops must be geographically relevant: Chosen stops should form a coherent path between #{@sloopy.origin} and #{@sloopy.destination} without significant detours.
      Can you serialize the data with a Hash wich looks like this:
       {
      "itineraries": [
      "summary": "add the short resume here",
      "steps": [
        {
          "route": "Outbound Itinerary: Paris to Athens",
          "period": "2024-12-02 to 2024-12-09",
          "details": [
            {
              "city": "Paris to Strasbourg",
              "transport": "Train (SNCF)",
              "cost": "€50",
              "duration": "2 hours",
              "activities": [
                { "name": "Visit the Strasbourg Cathedral", "address": "Place de la Cathédrale, 67000 Strasbourg" },
                { "name": "Explore Petite France", "address": "Grand île, 67000 Strasbourg" }
              ],
              "stay": "3 nights"
            },
            {
              "city": "Strasbourg to Munich",
              "transport": "Train (DB)",
              "cost": "€40",
              "duration": "3.5 hours",
              "activities": [
                { "name": "Visit the Marienplatz and New Town Hall", "address": "Marienplatz, 80331 München" },
                { "name": "Explore the English Garden", "address": "Englischer Garten, 80538 München" }
              ],
              "stay": "3 nights"
            },
            {
              "city": "Munich to Thessaloniki",
              "transport": "Bus (Flixbus)",
              "cost": "€100",
              "duration": "20 hours",
              "activities": [
                { "name": "Stroll along the waterfront", "address": "Leof. Nikis, 54625 Thessaloniki" },
                { "name": "Visit the White Tower", "address": "Leof. Nikis, 54625 Thessaloniki" }
              ],
              "stay": "1 night"
            },
            {
              "city": "Thessaloniki to Athens",
              "transport": "Bus (KTEL)",
              "cost": "€20",
              "duration": "5 hours",
              "activities": [],
              "stay": "7 nights"
            }
          ]
        },
        {
          "route": "Stay in Athens",
          "period": "2024-12-09 to 2024-12-16",
          "details": [
            {
              "city": "Athens",
              "activities": [
                { "name": "Visit the Acropolis", "address": "Acropolis, Athens 105 58" },
                { "name": "Explore the Acropolis Museum", "address": "Dionysiou Areopagitou 15, Athens 117 42" },
                { "name": "Walk through Plaka neighborhood", "address": "Plaka, Athens 105 58" },
                { "name": "Discover the Ancient Agora", "address": "Adrianou 24, Athens 105 55" },
                { "name": "Relax at National Garden", "address": "Vas. Sofias 1, Athens 105 57" },
                { "name": "Visit the Temple of Olympian Zeus", "address": "Vasilissis Olgas 1, Athens 105 57" },
                { "name": "Enjoy night views from Mount Lycabettus", "address": "Mount Lycabettus, Athens 114 71" }
              ]
            }
          ]
        },
        {
          "route": "Return Itinerary: Athens to Paris",
          "period": "2024-12-16 to 2024-12-26",
          "details": [
            {
              "city": "Athens to Corinth",
              "transport": "Train (TrainOSE)",
              "cost": "€10",
              "duration": "1 hour",
              "activities": [
                { "name": "Visit Ancient Corinth", "address": "Archaia Korinthos, Corinth 200 07" },
                { "name": "Explore the Temple of Apollo", "address": "Temple of Apollo, Corinth 200 07" }
              ],
              "stay": "2 nights"
            }
          ]
        }
      ],
      "budget": {
        "outbound": "€210",
        "return": "€170",
        "overall": "€380",
        "grand_total": "€550"
      }
    }
  ]
}
      PROMPT
  end

end
