class Category < ApplicationRecord
  belongs_to :user
  has_many :task_categories, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
