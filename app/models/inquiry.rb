class Inquiry < ApplicationRecord
  has_many :users
  has_many :houses

  validates_presence_of :interest_id
  validates_presence_of :subject
  validates_presence_of :message
end
