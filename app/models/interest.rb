class Interest < ApplicationRecord
has_many :users
has_many  :houses
validates_presence_of :user_id
validates_presence_of :house_id

validates :user_id, uniqueness: { scope: :house_id, message: "You have already shown your interest in this house"}
end


