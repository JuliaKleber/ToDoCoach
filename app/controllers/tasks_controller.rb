class TasksController < ApplicationController
  before_action :set_task, only: %i[dates_tasks show edit update toggle_completed destroy]
  before_action :set_last_collection_path, only: %i[todays_tasks dates_tasks tasks_without_date index]

  def todays_tasks
    @today = Time.now.strftime('%a, %d %B')
    @welcome_message = welcome_message
    @users_tasks = Task.where(user_id: current_user).where.not(due_date: nil)
    @tasks = []
    @users_tasks.each do |task|
      (@tasks << task) if task.due_date.strftime('%a, %d %B') == @today
    end
    @tasks_category_names = @tasks.map { |task| category_names(task.id) }
  end

  def dates_tasks
    @day = @task.due_date.strftime('%a, %d %B')
    @welcome_message = welcome_message
    @users_tasks = Task.where(user_id: current_user).where.not(due_date: nil)
    @tasks = []
    @users_tasks.each do |task|
      (@tasks << task) if task.due_date.strftime('%a, %d %B') == @day
    end
    @tasks_category_names = @tasks.map { |task| category_names(task.id) }
  end

  def tasks_without_date
    @welcome_message = welcome_message
    @tasks = Task.where(user_id: current_user).where(due_date: nil)
    @tasks_category_names = @tasks.map { |task| category_names(task.id) }
  end

  def index
    @tasks = Task.where(user_id: current_user).order(due_date: :asc, priority: :desc)
    @tasks = filter_tasks(@tasks)
    @tasks_without_due_date = @tasks.where(due_date: nil)
    @dates = dates_of_tasks(@tasks)
    @tasks_grouped_by_dates = group_tasks_by_date(@dates, @tasks.where.not(due_date: nil))
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
  end

  def create
    task_categories_attributes = task_params[:task_categories_attributes]
    create_params = task_params.except(:task_categories_attributes)
    formatted_task_categories_attributes = sanitize_categories(task_categories_attributes["0"][:category_id])
    @task = Task.new(create_params.merge({task_categories_attributes: formatted_task_categories_attributes}))
    @task.user = current_user
    if @task.save!
      redirect_to message_task_path(@task), notice: "Good job!
      Todo is very proud of you!"
      # ReminderJob.set(wait_until: @task.reminder_date).perform_later(@task) if @task.reminder_date != null
    else
      render :new
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
    @task = Task.find(params[:id])
    @task.destroy
    flash[:success] = "The to-do item was successfully deleted."

    redirect_to session[:last_collection_path], status: :see_other

  end

  def message
    @task = Task.find(params[:id])
    @remaining_task = Task.where(completed: false, priority: 'high').first
    @tasks_category_names = [category_names(@remaining_task[:id])]
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
    @tasks_with_due_date = tasks.where.not(due_date: nil)
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
  end

  # used in create and update
  def task_params
    params.require(:task).permit(:title, :description, :priority, :completed, :due_date, :reminder_date, :photo, task_categories_attributes: [category_id: []])
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

  # used in toggle_completed
  def check_for_achievements(task)
    threshold = [1, 5, 10, 20, 50, 100]
    achievements = {
      1 => ["Bronze", "You've completed 1 task! Keep it up!"],
      5 => ["Silver", "5 tasks completed! Well done!"],
      10 => ["Gold", "10 tasks completed! You're doing great!"],
      20 => ["Platinum", "20 tasks completed! You're on the right track!"],
      50 => ["Diamond", "50 tasks completed! Incredible achievement!"],
      100 => ["Master", "100 tasks completed! You're a task management master!"]
    }
    user_progress = UserProgress.find_by(user_id: current_user.id)
    user_progress.number_completed_all += 1
    user_progress.save
    if threshold.include?(user_progress.number_completed_all)
      new_achievement = UserAchievement.new(user_id: current_user.id, achievement_id: Achievement.find_by(name: achievements[user_progress.number_completed_all][0]).id)
      new_achievement.save
      redirect_to message_task_path(task), notice: "Congratulations! You earned a new batch"
    else
      redirect_to message_task_path(task), notice: "Task completed successfully"
    end
  end

  # def check_for_category_batch(task)
  #   threshold = [1, 5, 10, 20, 50, 100]
  #   user_progress = UserProgress.find(user_id: current_user.id)
  #   if task.category == 'Work'
  #     user_progress.number_completed_work += 1
  #     if threshold.includes(user_progress.number_completed_work)
  #       UserAchievement.new(user_id: current_user.id, achievement_id: Achievement.find()
  #       redirect_to message_task_path(task), notice: "Congratulations! You earned a new batch"
  #     elsif task.category == 'Personal'
  #     user_progress.number_completed_personal += 1
  #     redirect_to message_task_path(task), notice: "Congratulations! You earned a new batch" if threshold.includes(user_progress.number_completed_personal)
  #   elsif task.category == 'Groceries'
  #     user_progress.number_completed_groceries += 1
  #     redirect_to message_task_path(task), notice: "Congratulations! You earned a new batch" if threshold.includes(user_progress.number_completed_groceries)
  #   end
  # end

  # def check_for_priority_batch
  # end
end
