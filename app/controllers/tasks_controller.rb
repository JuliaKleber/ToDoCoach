class TasksController < ApplicationController
  before_action :set_task, only: %i[dates_tasks show edit update toggle_completed destroy]
  before_action :set_last_collection_path, only: %i[todays_tasks dates_tasks tasks_without_date index]

  def todays_tasks
    @today = Time.now.strftime('%a, %d %B')
    @welcome_message = welcome_message
    @users_tasks = current_user.tasks.select { |task| task.due_date.nil? == false }
    @tasks = []
    @users_tasks.each do |task|
      (@tasks << task) if task.due_date.strftime('%a, %d %B') == @today
    end
    @tasks_category_names = @tasks.map { |task| category_names(task.id) }
  end

  def dates_tasks
    @day = @task.due_date.strftime('%a, %d %B')
    @welcome_message = welcome_message
    @users_tasks = current_user.tasks.select { |task| task.due_date.nil? == false }
    @tasks = []
    @users_tasks.each do |task|
      (@tasks << task) if task.due_date.strftime('%a, %d %B') == @day
    end
    @tasks_category_names = @tasks.map { |task| category_names(task.id) }
  end

  def tasks_without_date
    @welcome_message = welcome_message
    @tasks = current_user.tasks.select { |task| task.due_date.nil? }
    @tasks_category_names = @tasks.map { |task| category_names(task.id) }
  end

  def index
    @tasks = current_user.tasks
    @tasks = filter_tasks(@tasks)
    @tasks_without_due_date = @tasks.select { |task| task.due_date.nil? }
    @dates = dates_of_tasks(@tasks)
    @tasks_grouped_by_dates = group_tasks_by_date(@dates, @tasks.select { |task| task.due_date.nil? == false })
  end

  # def filter_by
  #   @categorys = Category.where(nil)
  #   filtering_params(params).each do |key, value|
  #     @categorys = @categorys.public_send("filter_by_#{key}", value) if value.present?
  #   end
  # end

  def show
  end

  def new
    @task = Task.new
    @task.task_categories.build
    @task.task_users.build
  end

  def create
    task_categories_attributes = task_params[:task_categories_attributes]
    create_params = task_params.except(:task_categories_attributes)
    formatted_task_categories_attributes = sanitize_categories(task_categories_attributes["0"][:category_id])
    task = Task.new(create_params.merge({ task_categories_attributes: formatted_task_categories_attributes }))
    task.user = current_user
    if task.save
      user_ids_raw = params[:task][:task_user_ids]
      user_ids = user_ids_raw.select { |user_id| user_id.to_i.positive? }.map(&:to_i)
      user_ids << current_user.id
      user_ids.each { |user_id| TaskUser.create(task_id: task.id, user_id: user_id) }
      redirect_to message_task_path(task), notice: "Good job! Todo is very proud of you!"
      # ReminderJob.set(wait_until: @task.reminder_date).perform_later(@task) if @task.reminder_date != null
    else
      render :new, notice: "Task could not be saved."
    end
  end

  def edit
  end

  def update
    @task = Task.find(params[:id])
    # @old_task = @task
    @task.update(task_params)
    # ReminderJob.set(wait_until: @task.reminder_date).perform_later(@task) if @old_task.reminder_date != @task.reminder_date
    # redirect_to task_path(@task)
    respond_to do |format|
      format.html { redirect_to todays_tasks_path }
      format.text { render partial: "tasks/task_card", locals: { task: @task }, formats: [:html] }
    end
  end

  def toggle_completed
    @task.update(completed: !@task.completed)
    if @task.completed?
      check_for_achievements(@task)
    else
      redirect_back(fallback_location: todays_tasks_path)
    end
  end

  def destroy
    if @task.user == current_user
      @task.destroy
      flash[:success] = "The to-do item was successfully deleted."
      redirect_to session[:last_collection_path], status: :see_other
    else
      redirect_to tasks_path, notice: "You are not the creator of the task!"
    end
  end

  def message
    @achievement_earned = flash[:achievement_notice].present?
    @task = Task.find(params[:id])
    @remaining_task = Task.where(completed: false, priority: 'high').first
    @tasks_category_names = [category_names(@remaining_task[:id])]
    @latest_achievement = UserAchievement.last
  end

  private

  # def filtering_params(params)
  #   params.slice(:name)
  # end

  def set_task
    @task = Task.find(params[:id])
  end

  def set_last_collection_path
    session[:last_collection_path] = Rails.application.routes.recognize_path(request.fullpath)
  end

  # used in todays_tasks, dates_tasks and tasks_without_date
  def welcome_message
    todays_hour = Time.now.hour
    if todays_hour < 2
      @message = "Good evening #{current_user.user_name}"
    elsif todays_hour < 12
      @message = "Good morning #{current_user.user_name}"
    elsif todays_hour < 18
      @message = "Good afternoon #{current_user.user_name}"
    else
      @message = "Good evening #{current_user.user_name}"
    end
  end

  # used in todays_tasks, dates_tasks and tasks_without_date
  def category_names(task_id)
    task_categories = TaskCategory.where(task_id: task_id)
    @category_names = []
    task_categories.each do |tc|
      category = Category.where(id: tc.category_id)
      @category_names << category.first.name
    end
    return @category_names
  end

  # used in index
  def filter_tasks(tasks)
    search_query = params.dig(:search, :query)
    tasks = tasks.where("title ILIKE ?", "%#{search_query}%") if search_query.present?
    search_category_id = params.dig(:search, :category)
    if search_category_id.present? && search_category_id != 'all'
      tasks = tasks.joins(:task_categories).where(task_categories: { category_id: search_category_id })
    end
    search_priority = params.dig(:search, :priority)
    tasks = tasks.where(priority: search_priority) if search_priority.present? && search_priority != 'all'
    return tasks
  end

  # used in index
  def dates_of_tasks(tasks)
    @dates = Set.new([])
    @tasks_with_due_date = tasks.select { |task| task.due_date.nil? == false }
    @tasks_with_due_date.each do |task|
      @dates << task.due_date.strftime('%a, %d %B')
    end
    @dates = @dates.to_a
  end

  # used in index
  def group_tasks_by_date(dates, tasks_with_due_date)
    grouped_tasks = []
    dates.each do |date|
      dated_tasks = tasks_with_due_date.select { |task| task.due_date.strftime('%a, %d %B') == date }
      grouped_tasks << dated_tasks
    end
    return grouped_tasks
    # tasks_with_due_date.group_by(&:due_date) #=> { <date_one>: [..., ..., ...], <date_two>: [..., ..., ...] }
  end

  # used in create and update
  def task_params
    params.require(:task).permit(:title, :description, :due_date, :priority, :reminder_date, :completed, :photo, :task_user_ids, task_categories_attributes: [category_id: []])
  end

  # def task_users_params
  #   params.require(:task).permit(:task_user_ids)
  # end

  # used in create
  def sanitize_categories(attributes_array)
    attributes_array.compact_blank.map do |category_info|
      if category_info.to_i.zero?
        new_category = Category.create(user: current_user, name: category_info)
        { category_id: new_category.id }
      else
        { category_id: category_info.to_i }
      end
    end
  end

  # used in toggle_completed
  def check_for_achievements(task)
    user_progress = UserProgress.find_by(user_id: current_user.id)
    general_achievement = check_for_task_completed_achievement(task, user_progress)
    category_achievement = check_for_category_achievement(task, user_progress)
    priority_achievment = check_for_priority_achievement(task, user_progress)
    achievement_earned = general_achievement || category_achievement || priority_achievment
    if achievement_earned
      flash[:achievement_notice] = "Congratulations! You earned a new badch"
      redirect_to message_task_path(task)
    else
      redirect_to message_task_path(task), notice: "Task completed successfully"
    end
  end

  # used in check_for_achievements
  def check_for_task_completed_achievement(task, user_progress)
    threshold = [1, 5, 10, 20, 50, 100]
    achievements = {
      1 => ["Bronze", "You've completed 1 task! Keep it up!"],
      5 => ["Silver", "5 tasks completed! Well done!"],
      10 => ["Gold", "10 tasks completed! You're doing great!"],
      20 => ["Platinum", "20 tasks completed! You're on the right track!"],
      50 => ["Diamond", "50 tasks completed! Incredible achievement!"],
      100 => ["Master", "100 tasks completed! You're a task management master!"]
    }
    achievement_earned = false
    user_progress.number_completed_all += 1
    user_progress.save
    if threshold.include?(user_progress.number_completed_all)
      UserAchievement.create(user_id: current_user.id, achievement_id: Achievement.find_by(name: achievements[user_progress.number_completed_all][0]).id)
      achievement_earned = true
    end
    return achievement_earned
  end

  # used in check_for_achievements
  def check_for_category_achievement(task, user_progress)
    # grocery_achievements = {
    #   1 => ["Task Novice", "Completed your first grocery task. Welcome to the world of productive shopping!"],
    #   5 => ["Grocery Explorer", "Accomplished 5 grocery-related tasks. You're on your way to becoming a shopping pro!"],
    #   10 => ["Perfect 10 Shopper", "Successfully completed 10 grocery tasks. You've mastered the art of efficient shopping!"],
    #   20 => ["20-Task Triumph", "Achieved 20 grocery tasks! Your commitment to organized shopping is truly commendable."],
    #   50 => ["50 Grocery Conquests", "Completed 50 grocery tasks. You're a grocery hero, saving the day with every task!"],
    #   100 => ["Master Shopper", "Completed a whopping 100 grocery tasks. You are the undisputed master of the grocery list!"]
    # }
    # work_achievements = {
    #   1 => ["Work Task Rookie", "Completed your first work-related task. Welcome to the world of productivity at work!"],
    #   5 => ["Office Explorer", "Accomplished 5 work-related tasks. You're making strides in professional efficiency!"],
    #   10 => ["Perfect 10 Professional", "Successfully completed 10 work tasks. You're on your way to mastering your workday!"],
    #   20 => ["20-Task Triumph", "Achieved 20 work-related tasks! Your dedication to productivity is truly commendable."],
    #   50 => ["Corporate Conqueror", "Completed 50 work tasks. You're a work superhero, conquering tasks like a pro!"],
    #   100 => ["Task Mastermind", "Completed a monumental 100 work tasks. You are the undisputed master of workplace productivity!"]
    # }
    # personal_achievements = {
    #   1 => ["Personal Task Pioneer", "Completed your first personal task. Welcome to the world of organized personal life!"],
    #   5 => ["Life Explorer", "Accomplished 5 personal tasks. You're taking charge of your personal goals and aspirations!"],
    #   10 => ["Perfect 10 Achiever", "Successfully completed 10 personal tasks. You're on your way to mastering your personal to-do list!"],
    #   20 => ["20-Task Triumph", "Achieved 20 personal tasks! Your commitment to personal growth is truly commendable."],
    #   50 => ["Life Champion", "Completed 50 personal tasks. You're a personal achievement champion, conquering tasks with flair!"],
    #   100 => ["Task Zen Master", "Completed a Zen-like 100 personal tasks. You are the undisputed master of personal productivity!"]
    # }
    # threshold = [1, 5, 10, 20, 50, 100]
    # achievement_earned = false
    # if task.task.category == 'Groceries'
    #   user_progress.number_completed_groceries += 1
    #   if threshold.include?(user_progress.number_completed_all)
    #     UserAchievement.create(user_id: current_user.id, achievement_id: Achievement.find_by(name: grocery_achievements[user_progress.number_completed_groceries][0]).id)
    #     achievement_earned = true
    #   end
    # end
    # if task.task.category == 'Work'
    #   user_progress.number_completed_work += 1
    #   if threshold.include?(user_progress.number_completed_all)
    #     UserAchievement.create(user_id: current_user.id, achievement_id: Achievement.find_by(name: work_achievements[user_progress.number_completed_work][0]).id)
    #     achievement_earned = true
    #   end
    # end
    # if task.task.category == 'Personal'
    #   user_progress.number_completed_personal += 1
    #   if threshold.include?(user_progress.number_completed_all)
    #     UserAchievement.create(user_id: current_user.id, achievement_id: Achievement.find_by(name: personal_achievements[user_progress.number_completed_personal][0]).id)
    #     achievement_earned = true
    #   end
    # end
    # user_progress.save
    # return achievement_earned
  end

  # used in check_for_achievements
  def check_for_priority_achievement(task, user_progress)
    threshold = [1, 5, 10, 20, 50, 100]
    low_priority_achievements = {
      1 => ["Low Priority Starter", "Completed your first low-priority task. Kicking off your journey towards task management!"],
      5 => ["Easy-Going Achiever", "Accomplished 5 low-priority tasks. You're handling the less urgent tasks with ease!"],
      10 => ["Perfect 10 Laid Back", "Successfully completed 10 low-priority tasks. You've mastered the art of staying calm under low-pressure situations!"],
      20 => ["20-Task Serenity", "Achieved 20 low-priority tasks! Your ability to maintain composure in the face of low urgency is truly commendable."],
      50 => ["Zen Tasker", "Completed 50 low-priority tasks. You're a zen master, gliding through tasks with tranquility!"],
      100 => ["Chill Task Connoisseur", "Completed a serene 100 low-priority tasks. You've attained the highest level of chill in task management!"]
    }
    medium_priority_achievements = {
      1 => ["Medium Priority Explorer", "Completed your first medium-priority task. Welcome to the world of balanced task management!"],
      5 => ["Balanced Achiever", "Accomplished 5 medium-priority tasks. You're maintaining equilibrium in your task list!"],
      10 => ["Perfect 10 Equilibrium", "Successfully completed 10 medium-priority tasks. You're achieving balance in your task priorities!"],
      20 => ["20-Task Harmony", "Achieved 20 medium-priority tasks! Your knack for maintaining harmony in task management is truly commendable."],
      50 => ["Task Balancer", "Completed 50 medium-priority tasks. You're a master at balancing priorities!"],
      100 => ["Priority Maestro", "Completed a harmonious 100 medium-priority tasks. You've reached the pinnacle of task priority mastery!"]
    }
    high_priority_achievements = {
      1 => ["High Priority Dynamo", "Completed your first high-priority task. Welcome to the fast-paced world of urgent tasks!"],
      5 => ["Urgency Explorer", "Accomplished 5 high-priority tasks. You're navigating through urgency with skill and precision!"],
      10 => ["Perfect 10 Urgent Achiever", "Successfully completed 10 high-priority tasks. You're a force to be reckoned with in urgent matters!"],
      20 => ["20-Task Blitz", "Achieved 20 high-priority tasks! Your ability to handle urgency with speed and accuracy is truly commendable."],
      50 => ["Priority Warrior", "Completed 50 high-priority tasks. You're a warrior in the battlefield of urgent priorities!"],
      100 => ["Urgent Task Legend", "Completed a legendary 100 high-priority tasks. You're the undisputed legend of urgent task management!"]
    }
    achievement_earned = false
    if task.priority == 'low'
      user_progress.number_completed_low_priority += 1
      if threshold.include?(user_progress.number_completed_all)
        UserAchievement.create(user_id: current_user.id, achievement_id: Achievement.find_by(name: low_priority_achievements[user_progress.number_completed_low_priority][0]).id)
        achievement_earned = true
      end
    elsif task.priority == 'medium'
      user_progress.number_completed_medium_priority += 1
      if threshold.include?(user_progress.number_completed_all)
        UserAchievement.create(user_id: current_user.id, achievement_id: Achievement.find_by(name: medium_priority_achievements[user_progress.number_completed_medium_priority][0]).id)
        achievement_earned = true
      end
    elsif task.priority == 'high'
      user_progress.number_completed_high_priority += 1
      if threshold.include?(user_progress.number_completed_all)
        UserAchievement.create(user_id: current_user.id, achievement_id: Achievement.find_by(name: high_priority_achievements[user_progress.number_completed_high_priority][0]).id)
        achievement_earned = true
      end
    end
    user_progress.save
    return achievement_earned
  end

end
