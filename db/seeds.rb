puts 'Clearing the database ...'

TaskInvitation.destroy_all
UserProgress.destroy_all
UserAchievement.destroy_all
Achievement.destroy_all
TaskCategory.destroy_all
UserCategory.destroy_all
Category.destroy_all
TaskUser.destroy_all
Task.destroy_all
Follow.destroy_all
User.destroy_all

puts 'Creating users ...'

user_names = {
  "Aisiri" => "aisiri.jpg",
  "Bilal" => "bilal.jpg",
  "Elena" => "elena.jpg",
  "Julia" => "julia.jpg",
  "Minaj" => "minaj.jpg",
  "Kanye" => "kanye.jpg",
  "Beyonce" => "beyonce.jpg",
  "Obama" => "obama.jpg",
  "Jayz" => "jayz.jpg",
  "Eva" => "eva.jpg"
}

users = user_names.map do |name, file_name|
  user = User.new(user_name: name, email: "#{name.downcase}@todocoach.com", password: 'password')
  file = File.open(Rails.root.join("app/assets/images/#{file_name}"))
  user.photo.attach(io: file, filename: file_name, content_type: "image/jpg")
  user.save
  user
end

puts 'Creating categories ...'

personal_category = Category.create(name: 'Personal')
work_category = Category.create(name: 'Work')
groceries_category = Category.create(name: 'Groceries')

User.all.each do |user|
  UserCategory.create(user_id: user.id, category_id: personal_category.id)
  UserCategory.create(user_id: user.id, category_id: work_category.id)
  UserCategory.create(user_id: user.id, category_id: groceries_category.id)
end

user_specific_categories = [
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
  costum_category = Category.create(name: user_specific_categories.sample)
  UserCategory.create(user_id: user.id, category_id: costum_category.id)
end

puts 'Creating tasks for all users except of Eva ...'

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
puts current_time

User.where.not(user_name: 'Eva').each do |user|
  30.times do |n|
    random_task = tasks.sample
    due_date = (current_time + (n.to_f / 3).days + rand(0..8).hours + rand(0..60).minutes)
    task = user.tasks.create(
      title: random_task[0],
      description: random_task[1],
      priority: rand(Task.priorities[:low]..Task.priorities[:high]),
      completed: rand(0..3).zero?,
      due_date: due_date,
      reminder_date: due_date - rand(1..24).hours,
      user_id: user.id
    )
    task_categories = user.categories.sample(rand(1..2))
    task_categories.each do |category|
      TaskCategory.create(task_id: task.id, category_id: category.id)
    end
  end
  5.times do
    random_task = tasks.sample
    task = user.tasks.create(
      title: random_task[0],
      description: random_task[1],
      priority: rand(Task.priorities[:low]..Task.priorities[:high]),
      completed: rand(0..1).zero?,
      user_id: user.id
    )
    task_categories = user.categories.sample(rand(1..2))
    task_categories.each do |category|
      TaskCategory.create(task_id: task.id, category_id: category.id)
    end
  end
end

puts 'Creating tasks for Eva ...'

eva = User.find_by(user_name: 'Eva')

friday_evening = DateTime.new(2023, 12, 8, 20, 0, 0)
friday_evening_time = friday_evening.to_time

eva.tasks.create(
  title: "Buying a cinnamon roll",
  description: "I just love them! And I'll get one for Gerhard, too.",
  priority: "low",
  completed: false,
  user_id: eva.id,
  due_date: friday_evening_time - 0.2.hours,
  reminder_date: friday_evening_time - 1.hours
)

eva.tasks.create(
  title: "Talking with Gerhard",
  description: "Talking with Gerhard about this crazy To Do App I found",
  priority: "high",
  completed: false,
  user_id: eva.id,
  due_date: friday_evening_time,
  reminder_date: friday_evening_time - 2.hours
)

eva.tasks.create(
  title: "Jenny's Birthday Party",
  description: "Talking with Gerhard about this crazy To Do App I found",
  priority: "medium",
  completed: false,
  user_id: eva.id,
  due_date: friday_evening_time + 2.hours,
  reminder_date: friday_evening_time
)

User.where(user_name: 'Eva').each do |user|
  30.times do |n|
    random_task = tasks.sample
    due_date = (current_time + 1.days + (n.to_f / 3).days + rand(0..8).hours + rand(0..60).minutes)
    task = user.tasks.create(
      title: random_task[0],
      description: random_task[1],
      priority: rand(Task.priorities[:low]..Task.priorities[:high]),
      completed: rand(0..3).zero?,
      due_date: due_date,
      reminder_date: due_date - rand(1..24).hours,
      user_id: user.id
    )
    task_categories = user.categories.sample(rand(1..2))
    task_categories.each do |category|
      TaskCategory.create(task_id: task.id, category_id: category.id)
    end
  end
  5.times do
    random_task = tasks.sample
    task = user.tasks.create(
      title: random_task[0],
      description: random_task[1],
      priority: rand(Task.priorities[:low]..Task.priorities[:high]),
      completed: rand(0..1).zero?,
      user_id: user.id
    )
    task_categories = user.categories.sample(rand(1..2))
    task_categories.each do |category|
      TaskCategory.create(task_id: task.id, category_id: category.id)
    end
  end
end

puts 'Connecting users ...'

User.all.each do |user|
  followed = Follow.create(follower_id: user.id, followed_id: User.all.where.not(id: user.id).pluck(:id).sample)
  Follow.create(follower_id: user.id, followed_id: User.all.where.not(id: user.id).where.not(id: followed.followed_id).pluck(:id).sample)
end

require_relative 'seeds/achievements'

puts 'Connecting Eva to a task of someone else ...'

eva = User.find_by(user_name: 'Eva')
aisiri = User.find_by(user_name: 'Aisiri')

TaskInvitation.create(task_id: Task.where(user_id: aisiri.id).first.id, user_id: eva.id)
