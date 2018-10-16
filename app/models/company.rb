class Company < ApplicationRecord
  #attr_accessor :Name,:Website, :Address, :Size, :Founded, :Revenue, :Synopsis
  has_many :users
  has_many :houses

  validates :name, :presence => true
  validates :website, :presence => true
  validates :address, :presence => true
  validates :size, :presence => true
  validates :founded, :presence => true
  validates :revenue, :presence => true
  validates :synopsis, :presence => true
end
