class ReminderJob < ApplicationJob
  queue_as :default

  def perform(task)
  end
end
