class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy toggle_completed dates_tasks]

  def todays_tasks
    @today = Time.now.strftime('%a, %d %B')
    @welcome_message = welcome_message
    @all_tasks = Task.where(user_id: current_user).where.not(due_date: nil)
    @tasks = []
    @all_tasks.each do |task|
      (@tasks << task) if task.due_date.strftime('%a, %d %B') == @today
    end
    @tasks = @tasks.sort_by { |task| [task.due_date] }
    @tasks_category_names = @tasks.map do |task|
      category_names(task.id)
    end
  end

  def dates_tasks
    @day = @task.due_date.strftime('%a, %d %B')
    @welcome_message = welcome_message
    @users_tasks = Task.where(user_id: current_user).where.not(due_date: nil)
    @tasks = []
    @users_tasks.each do |task|
      (@tasks << task) if task.due_date.strftime('%a, %d %B') == @day
    end
    @tasks = @tasks.sort_by { |task| [task.due_date] }
    @tasks_category_names = @tasks.map do |task|
      category_names(task.id)
    end
  end

  def index
    @tasks = Task.where(user_id: current_user).order(due_date: :asc, priority: :desc)
    search_query = params.dig(:search, :query)
    @tasks = @tasks.where("title ILIKE ?", "%#{search_query}%") if search_query.present?
    search_category_id = params.dig(:search, :category)
    if search_category_id.present?
      @tasks = @tasks.joins(:task_categories).where(task_categories: { category_id: search_category_id })
    end
    @tasks_without_due_date = @tasks.where(due_date: nil)
    @dates = dates_of_tasks
    @tasks_grouped_by_dates = group_tasks_by_date
  end

  def filter_by
    @categorys = Category.where(nil)
    filtering_params(params).each do |key, value|
      @categorys = @categorys.public_send("filter_by_#{key}", value) if value.present?
    end
  end

  def show
  end

  def new
    @task = Task.new
    @task.task_categories.build
  end

  def create
    @task = Task.new(task_params)
    @task.user = current_user
    if @task.save!
      # ReminderJob.set(wait_until: @task.reminder_date).perform_later(@task) if @task.reminder_date != null
      redirect_to task_path(@task)
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
    # redirect_to motivational_message
    redirect_back(fallback_location: todays_tasks_path)
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    flash[:success] = "The to-do item was successfully deleted."
    redirect_to tasks_path, status: :see_other
  end

  private

  def filtering_params(params)
    params.slice(:name)
  end

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

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    # sanitize_categories
    params.require(:task).permit(:title, :description, :priority, :completed, :due_date, :reminder_date, :photo, task_categories_attributes: [category_id: []])
  end

  def sanitize_categories
    params[:task][:task_categories_attributes]["0"][:category_id] = params[:task][:task_categories_attributes]["0"][:category_id].compact_blank.map do |category_id|
      if category_id.to_i.zero?
        Category.create(user: current_user, name: category_id).id
      else
        category_id.to_i
      end
    end
  end

  def category_names(task_id)
    task_categories = TaskCategory.where(task_id: task_id)
    @category_names = []
    task_categories.each do |tc|
      category = Category.where(id: tc.category_id)
      @category_names << category.first.name
    end
    return @category_names
  end

  def dates_of_tasks
    @dates = Set.new([])
    @tasks_with_due_date = @tasks.where.not(due_date: nil)
    @tasks_with_due_date.each do |task|
      @dates << task.due_date.strftime('%a, %d %B')
    end
    @dates = @dates.to_a
  end

  def group_tasks_by_date
    @grouped_tasks = []
    @dates.each do |date|
      dated_tasks = @tasks_with_due_date.select { |task| task.due_date.strftime('%a, %d %B') == date }
      @grouped_tasks << dated_tasks
    end
  end
end
