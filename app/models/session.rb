class Session < ApplicationRecord
  belongs_to :campaign

  validates :date, presence: true
end