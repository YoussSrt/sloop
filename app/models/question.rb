class Question < ApplicationRecord
  belongs_to :user
  belongs_to :sloopy
  validates :user_question, presence: true
  after_create :fetch_ai_answer

  private

  def fetch_ai_answer
    ChatbotJob.perform_later(self, self.sloopy)
  end
end
