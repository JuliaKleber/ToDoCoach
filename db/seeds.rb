puts 'Clearing the database ...'

UserAchievementCongratulation.destroy_all
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

puts 'Creating achievements ...'

achievements = [
  ["Task Initiator", "Created your account! Welcome to the world of organized task management!"],
  ["Bronze", "You've completed 1 task! Keep it up!"],
  ["Silver", "5 tasks completed! Well done!"],
  ["Gold", "10 tasks completed! You're doing great!"],
  ["Platinum", "20 tasks completed! You're on the right track!"],
  ["Diamond", "50 tasks completed! Incredible achievement!"],
  ["Master", "100 tasks completed! You're a task management master!"],
  ["Task Novice", "Completed your first grocery task. Welcome to the world of productive shopping!"],
  ["Grocery Explorer", "Accomplished 5 grocery-related tasks. You're on your way to becoming a shopping pro!"],
  ["Perfect 10 Shopper", "Successfully completed 10 grocery tasks. You've mastered the art of efficient shopping!"],
  ["20-Grocery-Task Triumph", "Achieved 20 grocery tasks! Your commitment to organized shopping is truly commendable."],
  ["50 Grocery Conquests", "Completed 50 grocery tasks. You're a grocery hero, saving the day with every task!"],
  ["Master Shopper", "Completed a whopping 100 grocery tasks. You are the undisputed master of the grocery list!"],
  ["Work Task Rookie", "Completed your first work-related task. Welcome to the world of productivity at work!"],
  ["Office Explorer", "Accomplished 5 work-related tasks. You're making strides in professional efficiency!"],
  ["Perfect 10 Professional", "Successfully completed 10 work tasks. You're on your way to mastering your workday!"],
  ["20-Work-Task Triumph", "Achieved 20 work-related tasks! Your dedication to productivity is truly commendable."],
  ["Corporate Conqueror", "Completed 50 work tasks. You're a work superhero, conquering tasks like a pro!"],
  ["Task Mastermind", "Completed a monumental 100 work tasks. You are the undisputed master of workplace productivity!"],
  ["Personal Task Pioneer", "Completed your first personal task. Welcome to the world of organized personal life!"],
  ["Life Explorer", "Accomplished 5 personal tasks. You're taking charge of your personal goals and aspirations!"],
  ["Perfect 10 Achiever", "Successfully completed 10 personal tasks. You're on your way to mastering your personal to-do list!"],
  ["20-Personal-Task Triumph", "Achieved 20 personal tasks! Your commitment to personal growth is truly commendable."],
  ["Life Champion", "Completed 50 personal tasks. You're a personal achievement champion, conquering tasks with flair!"],
  ["Task Zen Master", "Completed a Zen-like 100 personal tasks. You are the undisputed master of personal productivity!"],
  ["Low Priority Starter", "Completed your first low-priority task. Kicking off your journey towards task management!"],
  ["Easy-Going Achiever", "Accomplished 5 low-priority tasks. You're handling the less urgent tasks with ease!"],
  ["Perfect 10 Laid Back", "Successfully completed 10 low-priority tasks. You've mastered the art of staying calm under low-pressure situations!"],
  ["20-Task Serenity", "Achieved 20 low-priority tasks! Your ability to maintain composure in the face of low urgency is truly commendable."],
  ["Zen Tasker", "Completed 50 low-priority tasks. You're a zen master, gliding through tasks with tranquility!"],
  ["Chill Task Connoisseur", "Completed a serene 100 low-priority tasks. You've attained the highest level of chill in task management!"],
  ["Medium Priority Explorer", "Completed your first medium-priority task. Welcome to the world of balanced task management!"],
  ["Balanced Achiever", "Accomplished 5 medium-priority tasks. You're maintaining equilibrium in your task list!"],
  ["Perfect 10 Equilibrium", "Successfully completed 10 medium-priority tasks. You're achieving balance in your task priorities!"],
  ["20-Task Harmony", "Achieved 20 medium-priority tasks! Your knack for maintaining harmony in task management is truly commendable."],
  ["Task Balancer", "Completed 50 medium-priority tasks. You're a master at balancing priorities!"],
  ["Priority Maestro", "Completed a harmonious 100 medium-priority tasks. You've reached the pinnacle of task priority mastery!"],
  ["High Priority Dynamo", "Completed your first high-priority task. Welcome to the fast-paced world of urgent tasks!"],
  ["Urgency Explorer", "Accomplished 5 high-priority tasks. You're navigating through urgency with skill and precision!"],
  ["Perfect 10 Urgent Achiever", "Successfully completed 10 high-priority tasks. You're a force to be reckoned with in urgent matters!"],
  ["20-Task Blitz", "Achieved 20 high-priority tasks! Your ability to handle urgency with speed and accuracy is truly commendable."],
  ["Priority Warrior", "Completed 50 high-priority tasks. You're a warrior in the battlefield of urgent priorities!"],
  ["Urgent Task Legend", "Completed a legendary 100 high-priority tasks. You're the undisputed legend of urgent task management!"]
]

achievements.each do |achievement|
  Achievement.create(name: achievement[0], description: achievement[1])
end

puts 'Creating categories ...'

personal_category = Category.create(name: 'personal')
work_category = Category.create(name: 'work')
groceries_category = Category.create(name: 'groceries')

# User.all.each do |user|
#   UserCategory.create(user_id: user.id, category_id: personal_category.id)
#   UserCategory.create(user_id: user.id, category_id: work_category.id)
#   UserCategory.create(user_id: user.id, category_id: groceries_category.id)
# end

# user_specific_categories = [
#   'Personal Goals',
#   'Fitness Routine',
#   'Travel Plans',
#   'Hobby Projects',
#   'Learning Journey',
#   'Family Events',
#   'Creative Ventures',
#   'Health and Wellness',
#   'Financial Planning'
# ]

# User.all.each do |user|
#   costum_category = Category.create(name: user_specific_categories.sample)
#   UserCategory.create(user_id: user.id, category_id: costum_category.id)
# end

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
  # user
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
personal_category = Category.find_by(name: 'personal')

friday_evening = DateTime.new(2023, 12, 8, 20, 0, 0)
friday_evening_time = friday_evening.to_time

task = eva.tasks.create(
  title: "Buying a cinnamon roll",
  description: "I just love them! And I'll get one for Gerhard, too.",
  priority: "low",
  completed: false,
  user_id: eva.id,
  due_date: friday_evening_time - 0.2.hours,
)
TaskCategory.create(task_id: task.id, category_id: personal_category.id)

task = eva.tasks.create(
  title: "Talking with Gerhard",
  description: "Talking with Gerhard about this crazy To Do App I found",
  priority: "high",
  completed: false,
  user_id: eva.id,
  due_date: friday_evening_time,
)
TaskCategory.create(task_id: task.id, category_id: personal_category.id)

task = eva.tasks.create(
  title: "Jenny's Birthday Party",
  description: "Talking with Gerhard about this crazy To Do App I found",
  priority: "medium",
  completed: false,
  user_id: eva.id,
  due_date: friday_evening_time + 2.hours,
)
TaskCategory.create(task_id: task.id, category_id: personal_category.id)

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

# require_relative 'seeds/achievements'

puts 'Inviting Eva to a task of someone else ...'

eva = User.find_by(user_name: 'Eva')
aisiri = User.find_by(user_name: 'Aisiri')

TaskInvitation.create(task_id: Task.where(user_id: aisiri.id).first.id, user_id: eva.id)

puts "Creating users' progresses ..."

User.all.each do |user|
  UserProgress.create(user_id: user.id)
end

# puts 'Giving each user a badge for an achievement ...'

# User.all.each do |user|
#   UserAchievement.create(user_id: user.id, achievement_id: Achievement.first.id, date: Time.now.to_date)
# end

# achievements_not_implemented = [
#   ["Multitasking Master", "You unlocked a new badge for adding tasks for 30 consecutive days"],
#   ["Busy Bee", "You have added 20 tasks in the category Work this week"],
#   ["Productivity Pro", "Completed 10 tasks in a single day"],
#   ["Task Explorer", "Explored and completed tasks in 3 different categories"],
#   ["Early Bird", "Completed a task before 8 AM"],
#   ["Night Owl", "Completed a task after midnight"],
#   ["Streak Starter", "Added tasks for 7 consecutive days"],
#   ["Weekend Warrior", "Completed tasks on both Saturday and Sunday"],
#   ["Focused Finisher", "Completed a task with high priority"],
#   ["Diverse Achiever", "Added tasks covering work, personal, and groceries categories in a single day"],
#   ["Master Planner", "Scheduled tasks for the entire week"],
#   ["Task Ninja", "Quickly completed a task within 10 minutes of adding it"],
#   ["Team Player", "Collaborated on a task with a fellow user"],
#   ["Task Marathoner", "Completed 5 tasks in a single day"],
# ]
