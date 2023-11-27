puts 'Clearing the database ...'

TaskCategory.destroy_all
User.destroy_all
Task.destroy_all
Category.destroy_all

puts 'Creating users ...'

# Create users
user_names = ['Aisiri', 'Bilal', 'Elena', 'Julia']

users = user_names.map do |name|
  User.create(user_name: name, email: "#{name.downcase}@todocoach.com", password: '123456')
end

puts User.all

# Create categories for each user
categories = users.flat_map do |user|
  ['Work', 'Personal', 'Study'].map do |category_name|
    user.categories.create(name: category_name)
  end
end

# Create tasks for each user due in the next two weeks and assign categories
users.each do |user|
  30.times do |n|
    due_date = Time.now + (n / 3).days
    task = user.tasks.create(
      title: "Task #{n + 1} for #{user.user_name}",
      description: "Description for task #{n + 1}",
      priority: rand(1..3),
      completed: false,
      due_date: due_date,
      reminder_date: due_date - 1.day
    )
    # Assign random categories to the task
    task.categories << categories.sample(rand(1..3))
  end
end
