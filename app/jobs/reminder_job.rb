class ReminderJob < ApplicationJob
  queue_as :default

  def perform(task)
    puts "Sending reminder for task #{task.id}: #{task.title}"
    # TaskReminderMailer.send_reminder_email(task).deliver_now
  end
end
