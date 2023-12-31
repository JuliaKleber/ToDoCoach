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
    @tasks = current_user.tasks.order(due_date: :asc, title: :asc)
    @tasks = filter_tasks(@tasks)
    @tasks_without_due_date = @tasks.select { |task| task.due_date.nil? }
    tasks_with_due_date = @tasks.select { |task| task.due_date.nil? == false }
    @tasks_grouped_by_dates = tasks_with_due_date.group_by { |task| task.due_date.to_date }
  end

  def show
    collaborators = @task.users.reject { |user| user == @task.user }
    @collaborators_list = collaborators.map(&:user_name).join(', ')
  end

  def new
    @task = Task.new
    @task.task_categories.build
  end

  def create
    task_categories_attributes = task_params[:task_categories_attributes]
    create_params = task_params.except(:task_categories_attributes)
    formatted_task_categories_attributes = sanitize_categories(task_categories_attributes["0"][:category_id])
    task = Task.new(create_params.merge({ task_categories_attributes: formatted_task_categories_attributes }))
    task.user = current_user
    if task.save
      create_user_invitations(task)
      TaskUser.create(task_id: task.id, user_id: current_user.id)
      redirect_to message_task_path(task), notice: "Good job! Todo is very proud of you!"
    else
      render :new, notice: "Task could not be saved."
    end
  end

  def edit
  end

  def update
    if @task.user == current_user
      task_model_params = task_params.except(:task_categories, :user_ids)
      if @task.update(task_model_params)
        @task.categories.destroy_all
        category_ids = params[:task][:category_ids].map(&:to_i).select { |id| id > 0 }
        category_ids.each { |category_id| TaskCategory.create(task_id: @task.id, category_id: category_id) }
        edit_task_users(@task)
        redirect_to task_path(@task), notice: 'Task details have been updated.'
      else
        render :edit, notice: 'Task could not be updated.'
      end
    else
      redirect_to task_path(@task), notice: 'Task could not be updated as you are not the task owner.'
    end
  end

  def toggle_completed
    @task.update(completed: !@task.completed)
    if @task.completed?
      check_for_achievements(@task)
    else
      decrement_user_progress(@task)
      redirect_back(fallback_location: todays_tasks_path)
    end
  end

  def destroy
    if @task.user == current_user
      TaskInvitation.where(task_id: @task.id).destroy_all
      @task.destroy
      TaskCategory.where(task_id: params[:id]).destroy_all if @task.users == []
      flash[:success] = "The to-do item was successfully deleted."
      redirect_to session[:last_collection_path], status: :see_other
    else
      TaskUser.where(user_id: current_user.id).where(task_id: params[:id]).destroy_all
      TaskCategory.where(task_id: params[:id]).destroy_all if @task.users == []
      redirect_to tasks_path, notice: "The to-do item was successfully deleted."
    end
  end

  def message
    @achievement_earned = flash[:achievement_notice].present?
    @task = Task.find(params[:id])
    @remaining_task = Task.where(user_id: current_user.id).where(completed: false, priority: 'high').first
    @remaining_task = Task.where(user_id: current_user.id).where(completed: false, priority: 'medium').first if @remaining_task.nil?
    @remaining_task = Task.where(user_id: current_user.id).where(completed: false, priority: 'low').first if @remaining_task.nil?
    @latest_achievement = UserAchievement.last
  end

  def add_user
    task_user = TaskUser.new(user_id: current_user.id, task_id: params[:id])
    if task_user.save
      invitation = TaskInvitation.where(user_id: current_user.id).where(task_id: params[:id])
      invitation.destroy_all
      redirect_to feed_user_path, notice: "You were added to the task!"
    else
      redirect_to feed_user_path, notice: "You could not be added to the task."
    end
  end

  private

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

  # used in create and update
  def task_params
    params.require(:task).permit(:title, :description, :due_date, :priority, :reminder_date, :completed, :user_ids, task_categories_attributes: [category_id: []])
  end

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

  # used in create
  def create_user_invitations(task)
    user_ids_raw = params[:task][:user_ids]
    user_ids = user_ids_raw.select { |user_id| user_id.to_i.positive? }.map(&:to_i)
    user_ids.each { |user_id| TaskInvitation.create(task_id: task.id, user_id: user_id) }
  end

  # used in update
  def edit_task_users(task)
    already_connected_user_ids = task.users.where.not(id: current_user.id).pluck(:id)
    already_invited_user_ids = TaskInvitation.where(task_id: task.id).pluck(:user_id)
    new_user_ids = params[:task][:user_ids].select { |user_id| user_id.to_i.positive? }.map(&:to_i)
    new_user_ids.each do |user_id|
      TaskInvitation.create(task_id: task.id, user_id: user_id) unless already_connected_user_ids.include?(user_id)
    end
    TaskInvitation.where(task_id: task.id, user_id: already_invited_user_ids - new_user_ids).destroy_all
    TaskUser.where(task_id: task.id, user_id: already_connected_user_ids - new_user_ids).destroy_all
  end

  # used in toggle_completed
  def check_for_achievements(task)
    user_progress = UserProgress.find_by(user_id: current_user.id)
    general_achievement = check_for_task_completed_achievement(task, user_progress)
    category_achievement = check_for_category_achievements(task, user_progress)
    priority_achievement = check_for_priority_achievements(task, user_progress)
    achievement_earned = general_achievement || category_achievement || priority_achievement
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
      [1, 5, 10, 20, 50].each do |number|
        achievement_name = achievements[number][0]
        achievement = Achievement.find_by(name: achievement_name)
        if achievement.present?
          user_achievement = UserAchievement.find_by(user_id: current_user.id, achievement_id: achievement.id)
          if user_achievement.present?
            user_achievement.destroy!
          end
        end
      end
      UserAchievement.create(user_id: current_user.id, achievement_id: Achievement.find_by(name: achievements[user_progress.number_completed_all][0]).id, date: Time.now.to_date)
      achievement_earned = true
    end
    return achievement_earned
  end

  # used in check_for_achievements
  def check_for_category_achievements(task, user_progress)
    category_achievements = {
      'groceries' => {
        1 => ["Task Novice", "Completed your first grocery task. Welcome to the world of productive shopping!"],
        5 => ["Grocery Explorer", "Accomplished 5 grocery-related tasks. You're on your way to becoming a shopping pro!"],
        10 => ["Perfect 10 Shopper", "Successfully completed 10 grocery tasks. You've mastered the art of efficient shopping!"],
        20 => ["20-Task Triumph", "Achieved 20 grocery tasks! Your commitment to organized shopping is truly commendable."],
        50 => ["50 Grocery Conquests", "Completed 50 grocery tasks. You're a grocery hero, saving the day with every task!"],
        100 => ["Master Shopper", "Completed a whopping 100 grocery tasks. You are the undisputed master of the grocery list!"]
      },
      'work' => {
        1 => ["Work Task Rookie", "Completed your first work-related task. Welcome to the world of productivity at work!"],
        5 => ["Office Explorer", "Accomplished 5 work-related tasks. You're making strides in professional efficiency!"],
        10 => ["Perfect 10 Professional", "Successfully completed 10 work tasks. You're on your way to mastering your workday!"],
        20 => ["20-Task Triumph", "Achieved 20 work-related tasks! Your dedication to productivity is truly commendable."],
        50 => ["Corporate Conqueror", "Completed 50 work tasks. You're a work superhero, conquering tasks like a pro!"],
        100 => ["Task Mastermind", "Completed a monumental 100 work tasks. You are the undisputed master of workplace productivity!"]
      },
      'personal' => {
        1 => ["Personal Task Pioneer", "Completed your first personal task. Welcome to the world of organized personal life!"],
        5 => ["Life Explorer", "Accomplished 5 personal tasks. You're taking charge of your personal goals and aspirations!"],
        10 => ["Perfect 10 Achiever", "Successfully completed 10 personal tasks. You're on your way to mastering your personal to-do list!"],
        20 => ["20-Task Triumph", "Achieved 20 personal tasks! Your commitment to personal growth is truly commendable."],
        50 => ["Life Champion", "Completed 50 personal tasks. You're a personal achievement champion, conquering tasks with flair!"],
        100 => ["Task Zen Master", "Completed a Zen-like 100 personal tasks. You are the undisputed master of personal productivity!"]
      }
    }
    threshold = [1, 5, 10, 20, 50, 100]
    achievement_earned = false
    task.categories.pluck(:name).each do |category_name|
      if ['work', 'personal', 'groceries'].include?(category_name)
        user_progress.increment!("number_completed_#{category_name}".to_sym)
        if threshold.include?(user_progress.send("number_completed_#{category_name}"))
          [1, 5, 10, 20, 50].each do |number|
            achievement_name = category_achievements[category_name][number][0]
            achievement = Achievement.find_by(name: achievement_name)
            if achievement.present?
              user_achievement = UserAchievement.find_by(user_id: current_user.id, achievement_id: achievement.id)
              user_achievement.destroy! if user_achievement.present?
            end
          end
          achievement_name = category_achievements[category_name][user_progress.send("number_completed_#{category_name}")][0]
          achievement = Achievement.find_by(name: achievement_name)
          UserAchievement.create(user_id: current_user.id, achievement_id: achievement.id, date: Time.now.to_date)
          achievement_earned = true
        end
      end
    end
    return achievement_earned
  end

  # used in check_for_achievements
  def check_for_priority_achievements(task, user_progress)
    priority_achievements = {
      'low' => {
        1 => ["Low Priority Starter", "Completed your first low-priority task. Kicking off your journey towards task management!"],
        5 => ["Easy-Going Achiever", "Accomplished 5 low-priority tasks. You're handling the less urgent tasks with ease!"],
        10 => ["Perfect 10 Laid Back", "Successfully completed 10 low-priority tasks. You've mastered the art of staying calm under low-pressure situations!"],
        20 => ["20-Task Serenity", "Achieved 20 low-priority tasks! Your ability to maintain composure in the face of low urgency is truly commendable."],
        50 => ["Zen Tasker", "Completed 50 low-priority tasks. You're a zen master, gliding through tasks with tranquility!"],
        100 => ["Chill Task Connoisseur", "Completed a serene 100 low-priority tasks. You've attained the highest level of chill in task management!"]
      },
      'medium' => {
        1 => ["Medium Priority Explorer", "Completed your first medium-priority task. Welcome to the world of balanced task management!"],
        5 => ["Balanced Achiever", "Accomplished 5 medium-priority tasks. You're maintaining equilibrium in your task list!"],
        10 => ["Perfect 10 Equilibrium", "Successfully completed 10 medium-priority tasks. You're achieving balance in your task priorities!"],
        20 => ["20-Task Harmony", "Achieved 20 medium-priority tasks! Your knack for maintaining harmony in task management is truly commendable."],
        50 => ["Task Balancer", "Completed 50 medium-priority tasks. You're a master at balancing priorities!"],
        100 => ["Priority Maestro", "Completed a harmonious 100 medium-priority tasks. You've reached the pinnacle of task priority mastery!"]
      },
      'high' => {
        1 => ["High Priority Dynamo", "Completed your first high-priority task. Welcome to the fast-paced world of urgent tasks!"],
        5 => ["Urgency Explorer", "Accomplished 5 high-priority tasks. You're navigating through urgency with skill and precision!"],
        10 => ["Perfect 10 Urgent Achiever", "Successfully completed 10 high-priority tasks. You're a force to be reckoned with in urgent matters!"],
        20 => ["20-Task Blitz", "Achieved 20 high-priority tasks! Your ability to handle urgency with speed and accuracy is truly commendable."],
        50 => ["Priority Warrior", "Completed 50 high-priority tasks. You're a warrior in the battlefield of urgent priorities!"],
        100 => ["Urgent Task Legend", "Completed a legendary 100 high-priority tasks. You're the undisputed legend of urgent task management!"]
      }
    }
    threshold = [1, 5, 10, 20, 50, 100]
    achievement_earned = false
    user_progress.increment!("number_completed_#{task.priority}_priority".to_sym)
    if threshold.include?(user_progress.send("number_completed_#{task.priority}_priority"))
      [1, 5, 10, 20, 50].each do |number|
        achievement_name = priority_achievements[task.priority][number][0]
        achievement = Achievement.find_by(name: achievement_name)
        if achievement.present?
          user_achievement = UserAchievement.find_by(user_id: current_user.id, achievement_id: achievement.id)
          user_achievement.destroy! if user_achievement.present?
        end
      end
      achievement_name = priority_achievements[task.priority][user_progress.send("number_completed_#{task.priority}_priority")][0]
      achievement = Achievement.find_by(name: achievement_name)
      UserAchievement.create(user_id: current_user.id, achievement_id: achievement.id, date: Time.now.to_date)
      achievement_earned = true
    end
    return achievement_earned
  end

  def decrement_user_progress(task)
    user_progress = UserProgress.find_by(user_id: current_user.id)
    user_progress.number_completed_all -= 1
    user_progress.number_completed_low_priority -= 1 if task.priority == "low"
    user_progress.number_completed_medium_priority -= 1 if task.priority == "medium"
    user_progress.number_completed_high_priority -= 1 if task.priority == "high"
    user_progress.number_completed_personal -= 1 if task.categories.include?(Category.find_by(name: 'personal'))
    user_progress.number_completed_groceries -= 1 if task.categories.include?(Category.find_by(name: 'groceries'))
    user_progress.number_completed_work -= 1 if task.categories.include?(Category.find_by(name: 'work'))
    user_progress.save
  end
end
