puts "Creating users' progresses ..."

User.all.each do |user|
  UserProgress.create(user_id: user.id)
end

puts 'Creating achievements ...'

achievements = [
  ["Bronze", "You've completed 1 task! Keep it up!"],
  ["Silver", "5 tasks completed! Well done!"],
  ["Gold", "10 tasks completed! You're doing great!"],
  ["Platinum", "20 tasks completed! You're on the right track!"],
  ["Diamond", "50 tasks completed! Incredible achievement!"],
  ["Master", "100 tasks completed! You're a task management master!"]
]

achievements.each do |achievement|
  Achievement.create(name: achievement[0], description: achievement[1])
end

# achievements_not_yet_implemented.each do |achievement|
#   Achievement.create(name: achievement[0], description: achievement[1])
# end

# old_achievements.each do |achievement|
#   Achievement.create(name: achievement[0], description: achievement[1])
# end



# User.all.each do |user|
#   user_achievement1 = UserAchievement.create(user_id: user.id, achievement_id: Achievement.all.sample.id)
#   user_achievement2 = UserAchievement.create(user_id: user.id, achievement_id: Achievement.all.where.not(id: user_achievement1.achievement_id).sample.id)
#   UserAchievement.create(user_id: user.id, achievement_id: Achievement.all.where.not(id: user_achievement1.achievement_id).where.not(id: user_achievement2.achievement_id).sample.id)
# end

# achievements_not_yet_implemented = [
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

# old_achievements = [
#   ["Mindful Achiever", "Completed a task with mindful intent"],
#   ["Explorer", "Added a task related to a new hobby or interest"],
#   ["Health Hero", "Completed a task related to health and wellness"],
#   ["Social Butterfly", "Added tasks for social events or gatherings"],
#   ["Tech Guru", "Added and completed a task related to technology or learning"],
#   ["Inspiration Seeker", "Added a task inspired by something you read or heard"],
#   ["Tech Detox Master", "Completed a task after a day without screens"],
#   ["Creative Dynamo", "Added a task for a creative project or idea"]
#   ["Memory Maker", "Added a task to capture a special memory"],
#   ["Learning Legend", "Added a task related to a new skill you want to learn"],
#   ["Explorer of the Unknown", "Completed a task outside your comfort zone"],
#   ["Bookworm", "Added a task to read a chapter of a book"],
#   ["Gratitude Journalist", "Completed a task expressing gratitude"],
#   ["Adventurer", "Added a task for a spontaneous adventure or outing"],
#   ["Chef Extraordinaire", "Completed a task to try a new recipe"],
#   ["Green Thumb", "Completed a task related to gardening or plants"],
# ]
