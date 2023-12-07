puts "Creating users' progresses ..."

User.all.each do |user|
  UserProgress.create(user_id: user.id)
end

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

puts 'Giving each user a badge for an achievement ...'

User.all.each do |user|
  UserAchievement.create(user_id: user.id, achievement_id: Achievement.first)
end

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
