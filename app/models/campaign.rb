class Campaign < ApplicationRecord
  has_many :memberships
  has_many :players, through: :memberships
  has_many :sessions, dependent: :destroy
end