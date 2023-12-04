puts 'Clearing the database ...'

UserAchievement.destroy_all
Achievement.destroy_all
TaskCategory.destroy_all
Task.destroy_all
Category.destroy_all
Follow.destroy_all
User.destroy_all

puts 'Creating users ...'

user_names = ['Aisiri', 'Bilal', 'Elena', 'Julia', 'Ali']

users = user_names.map do |name|
  User.create(user_name: name, email: "#{name.downcase}@todocoach.com", password: 'password')
end

puts 'Creating categories ...'

User.all.each do |user|
  general_categories = ['Work', 'Personal', 'Groceries'].map do |category_name|
    category = user.categories.create(name: category_name, user_id: user.id)
  end
end

user_specific_categories = [
  'Work Projects',
  'Personal Goals',
  'Fitness Routine',
  'Travel Plans',
  'Hobby Projects',
  'Learning Journey',
  'Family Events',
  'Creative Ventures',
  'Health and Wellness',
  'Financial Planning'
]

User.all.each do |user|
  category = user.categories.create(name: user_specific_categories.sample)
end

puts 'Creating tasks ...'

tasks = [
  ["Doing the groceries", "Pick up fresh produce and household essentials from the local grocery store."],
  ["Dentist appointment", "Visit the dentist for a routine checkup and cleaning."],
  ["Buying a birthday present for Charles", "Select a thoughtful birthday gift for your friend Charles."],
  ["Meeting with the project team", "Collaborate with the project team to discuss progress and upcoming tasks."],
  ["Writing a blog post", "Create engaging content for your blog on a topic of interest."],
  ["Calling mom", "Catch up with your mom and share the latest updates."],
  ["Preparing for the presentation", "Gather information and create visuals for an upcoming presentation."],
  ["Gym workout", "Engage in a full-body workout session at the gym."],
  ["Sending invoices", "Issue invoices to clients for completed services or products."],
  ["Attending a networking event", "Expand your professional network at a local networking event."],
  ["Book club meeting", "Read and prepare for the discussion at the upcoming book club meeting."],
  ["Walking the dog", "Take your furry friend for a refreshing walk in the park."],
  ["Paying bills", "Manage and pay your monthly bills to stay on top of your finances."],
  ["Updating resume", "Revise and update your resume with recent accomplishments and skills."],
  ["Cooking dinner", "Prepare a delicious and nutritious dinner for yourself or your family."],
  ["Researching new technology trends", "Explore the latest advancements in technology to stay informed."],
  ["Volunteering at the local shelter", "Offer your time to support and help at the nearby animal shelter."],
  ["Planning a weekend getaway", "Research and plan a relaxing weekend getaway destination."],
  ["Attending a yoga class", "Participate in a yoga class to rejuvenate your mind and body."],
  ["Fixing a leaky faucet", "Address and repair a leaky faucet in your home."],
  ["Reading a chapter of a novel", "Enjoy some leisure time by reading a chapter of a captivating novel."],
  ["Organizing the closet", "Declutter and organize your closet for a more efficient space."],
  ["Learning a new recipe", "Experiment with a new recipe to broaden your culinary skills."],
  ["Scheduling a doctor's appointment", "Book an appointment with your healthcare provider for a routine checkup."],
  ["Taking the car for maintenance", "Schedule and take your car for regular maintenance to ensure optimal performance."],
  ["Attending a language learning meetup", "Practice and improve your language skills at a local language learning meetup."],
  ["Watching a documentary", "Explore a documentary on a topic that interests and educates you."],
  ["Planting flowers in the garden", "Enhance your garden by planting colorful and fragrant flowers."],
  ["Attending a community clean-up event", "Contribute to your community by participating in a clean-up event."],
  ["Creating a budget for the month", "Plan and create a budget to manage your finances for the upcoming month."]
]

current_time = Time.now
User.all.each do |user|
  30.times do |n|
    random_task = tasks.sample
    due_date = (current_time + (n.to_f / 3).days + rand(0..8).hours + rand(0..60).minutes)
    task = user.tasks.create(
      title: random_task[0],
      description: random_task[1],
      priority: rand(Task.priorities[:low]..Task.priorities[:high]),
      completed: rand(2).zero?,
      due_date: due_date,
      reminder_date: due_date - rand(1..24).hours
    )
    task_categories = user.categories.sample(rand(1..2)).compact
    task_categories.each do |category|
      TaskCategory.create(task: task, category: category)
    end
  end
  5.times do
    random_task = tasks.sample
    task = user.tasks.create(
      title: random_task[0],
      description: random_task[1],
      priority: rand(Task.priorities[:low]..Task.priorities[:high]),
      completed: rand(0..1).zero?
    )
    task_categories = user.categories.sample(rand(1..2)).compact
    task_categories.each do |category|
      TaskCategory.create(task: task, category: category)
    end
  end
end

puts 'Connecting users ...'

User.all.each do |user|
  followed = Follow.create(follower_id: user.id, followed_id: User.all.where.not(id: user.id).pluck(:id).sample)
  Follow.create(follower_id: user.id, followed_id: User.all.where.not(id: user.id).where.not(id: followed.followed_id).pluck(:id).sample)
end

puts 'Creating achievements ...'

achievements = [
  ["Multitasking Master", "You unlocked a new badge for adding tasks for 30 consecutive days"],
  ["Busy Bee", "You have added 20 tasks in the category Work this week"],
  ["Productivity Pro", "Completed 10 tasks in a single day"],
  ["Task Explorer", "Explored and completed tasks in 5 different categories"],
  ["Early Bird", "Completed a task before 8 AM"],
  ["Night Owl", "Completed a task after midnight"],
  ["Streak Starter", "Added tasks for 7 consecutive days"],
  ["Weekend Warrior", "Completed tasks on both Saturday and Sunday"],
  ["Focused Finisher", "Completed a task with high priority"],
  ["Diverse Achiever", "Added tasks covering work, personal, and fitness categories in a single day"],
  ["Master Planner", "Scheduled tasks for the entire week"],
  ["Inspiration Seeker", "Added a task inspired by something you read or heard"],
  ["Mindful Achiever", "Completed a task with mindful intent"],
  ["Explorer", "Added a task related to a new hobby or interest"],
  ["Task Ninja", "Quickly completed a task within 10 minutes of adding it"],
  ["Team Player", "Collaborated on a task with a fellow user"],
  ["Tech Guru", "Added and completed a task related to technology or learning"],
  ["Health Hero", "Completed a task related to health and wellness"],
  ["Social Butterfly", "Added tasks for social events or gatherings"],
  ["Memory Maker", "Added a task to capture a special memory"],
  ["Green Thumb", "Completed a task related to gardening or plants"],
  ["Bookworm", "Added a task to read a chapter of a book"],
  ["Chef Extraordinaire", "Completed a task to try a new recipe"],
  ["Adventurer", "Added a task for a spontaneous adventure or outing"],
  ["Gratitude Journalist", "Completed a task expressing gratitude"],
  ["Tech Detox Master", "Completed a task after a day without screens"],
  ["Learning Legend", "Added a task related to a new skill you want to learn"],
  ["Explorer of the Unknown", "Completed a task outside your comfort zone"],
  ["Task Marathoner", "Completed 5 tasks in a single day"],
  ["Creative Dynamo", "Added a task for a creative project or idea"]
]

achievements.each do |achievement|
  Achievement.create(name: achievement[0], description: achievement[1])
end

User.all.each do |user|
  user_achievement1 = UserAchievement.create(user_id: user.id, achievement_id: Achievement.all.sample.id)
  user_achievement2 = UserAchievement.create(user_id: user.id, achievement_id: Achievement.all.where.not(id: user_achievement1.achievement_id).sample.id)
  UserAchievement.create(user_id: user.id, achievement_id: Achievement.all.where.not(id: user_achievement1.achievement_id).where.not(id: user_achievement2.achievement_id).sample.id)
end
