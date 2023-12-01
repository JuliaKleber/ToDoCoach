puts 'Clearing the database ...'

TaskCategory.destroy_all
Task.destroy_all
Category.destroy_all
Follow.destroy_all
User.destroy_all

puts 'Creating users ...'

# Create users
user_names = ['Aisiri', 'Bilal', 'Elena', 'Julia']

users = user_names.map do |name|
  User.create(user_name: name, email: "#{name.downcase}@todocoach.com", password: 'password')
end

puts 'Creating categories ....'

# Create categories for each user
categories = ['Work', 'Personal', 'Groceries'].map do |category_name|
  User.last.categories.create(name: category_name)
end

puts 'Creating tasks...'

task_titles = [
  "Doing the groceries",
  "Dentist appointment",
  "Buying a birthday present for Charles",
  "Meeting with the project team",
  "Writing a blog post",
  "Calling mom",
  "Preparing for the presentation",
  "Gym workout",
  "Sending invoices",
  "Attending a networking event",
  "Book club meeting",
  "Walking the dog",
  "Paying bills",
  "Updating resume",
  "Cooking dinner",
  "Researching new technology trends",
  "Volunteering at the local shelter",
  "Planning a weekend getaway",
  "Attending a yoga class",
  "Fixing a leaky faucet",
  "Reading a chapter of a novel",
  "Organizing the closet",
  "Learning a new recipe",
  "Scheduling a doctor's appointment",
  "Taking the car for maintenance",
  "Attending a language learning meetup",
  "Watching a documentary",
  "Planting flowers in the garden",
  "Attending a community clean-up event",
  "Creating a budget for the month"
]

# Create tasks for each user due in the next two weeks and assign categories
current_time = Time.now
users.each do |user|
  30.times do |n|
    task_title = task_titles.sample
    due_date = (current_time + (n.to_f / 3).days)
    task = user.tasks.create(
      title: task_title,
      description: "Description for '#{task_title}'",
      priority: rand(Task.priorities[:low]..Task.priorities[:high]),
      completed: rand(0..1).zero?,
      due_date: due_date,
      reminder_date: due_date - 1.day
    )

    # Assign random categories to the task through TaskCategory
    task_categories = categories.sample(rand(1..3))
    task_categories.each do |category|
      TaskCategory.create(task: task, category: category)
    end
  end
  5.times do |n|
    task_title = task_titles.sample
    task = user.tasks.create(
      title: task_title,
      description: "Description for '#{task_title}'",
      priority: rand(Task.priorities[:low]..Task.priorities[:high]),
      completed: rand(0..1).zero?
    )

    # Assign random categories to the task through TaskCategory
    task_categories = categories.sample(rand(1..3))
    task_categories.each do |category|
      TaskCategory.create(task: task, category: category)
    end
  end
end
