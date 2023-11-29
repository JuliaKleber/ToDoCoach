class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy toggle_completed dates_tasks]

  def todays_tasks
    @today = Time.now.strftime('%a, %d %B')
    @welcome_message = welcome_message
    @all_tasks = Task.where(user_id: current_user)
    @tasks = []
    @all_tasks.each do |task|
      (@tasks << task) if task.due_date.strftime('%a, %d %B') == @today
    end
    @tasks = @tasks.sort_by { |task| [task.due_date, -task.priority] }
    @tasks_category_names = @tasks.map do |task|
      category_names(task.id)
    end
  end

  def dates_tasks
    @day = @task.due_date.strftime('%a, %d %B')
    @welcome_message = welcome_message
    @all_tasks = Task.where(user_id: current_user)
    @tasks = []
    @all_tasks.each do |task|
      (@tasks << task) if task.due_date.strftime('%a, %d %B') == @day
    end
    @tasks = @tasks.sort_by { |task| [task.due_date, -task.priority] }
  end

  def index
    @tasks = Task.where(user_id: current_user)
    @tasks = @tasks.order(due_date: :asc, priority: :desc)

    search_query = params.dig(:search, :query)
    if search_query.present?
      @tasks = @tasks.where("title ILIKE ?", "%#{search_query}%")
    end
    search_category_id = params.dig(:search, :category)
    if search_category_id.present?
      @tasks = @tasks.joins(:task_categories).where(task_categories: { category_id: search_category_id})
    end
    @dates = Set.new([])
    @tasks.each do |task|
      @dates << task.due_date.strftime('%a, %d %B')
    end
    @dates = @dates.to_a
    @grouped_tasks = []
    @dates.each do |date|
      dated_tasks = @tasks.select { |task| task.due_date.strftime('%a, %d %B') == date }
      @grouped_tasks << dated_tasks
    end
  end

  def filter_by
    @categorys = Category.where(nil)
    filtering_params(params).each do |key, value|
      @categorys = @categorys.public_send("filter_by_#{key}", value) if value.present?
    end
  end

  def show
    category_names(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.user = current_user
    if @task.save
      redirect_to task_path(@task)
      ReminderJob.set(wait_until: @task.reminder_date).perform_later
    else
      render :new
    end
  end

  def edit
  end

  def update
    @task = Task.find(params[:id])
    @task.update(task_params)
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
    params.require(:task).permit(:title, :description, :priority, :completed, :due_date, :reminder_date, :photo)
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
end
