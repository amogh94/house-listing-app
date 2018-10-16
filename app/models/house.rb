class House < ApplicationRecord
  #attr_accessor :company_id,:location, :sq_footage, :year_build, :style, :list_price, :floors, :basement, :current_owner, :realtor_id
  has_many :users
  belongs_to :company

  validates :company_id, :presence => true
  validates :location, :presence => true
  validates :sq_footage, :presence => true
  validates :year_build, :presence => true
  validates :style, :presence => true
  validates :list_price, :presence => true
  validates :floors, :presence => true
  validates :basement, :presence => true
  validates :current_owner, :presence => true
  validates :realtor_id, :presence => true
end
