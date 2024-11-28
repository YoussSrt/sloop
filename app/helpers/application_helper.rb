module ApplicationHelper
  def category_title(category)
    case category 
    when :favorite_activities
      "What are your favorite activities?"
    when :ideal_travel_pace
      "What is your ideal travel pace?"
    when :exciting_experiences
      "What experiences excite you the most?"
    when :traveling_with
      "Who are you traveling with?"
    when :preferred_vibe
      "What vibe do you prefer for your trips?"
    when :main_travel_goal
      "What is your main travel goal?"
    end    
  end
end
