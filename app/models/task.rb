class Task < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: {minimum: 10, maximum: 60}

  validates :description, presence: true, length: {maximum: 250}
end
