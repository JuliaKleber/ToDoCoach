class Category < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  scope :filter_by_starts_with, -> (category) {where("name 1like ?", "#{name}%")}
end
