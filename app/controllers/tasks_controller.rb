class TasksController < ApplicationController
  before_action :set_task, only: [:show]

  def todays_tasks
    @tasks = Task.where(user_id: current_user)
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

  def index
    @tasks = Task.where(user_id: current_user)
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

  def show
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.user = current_user
    if @task.save
      redirect_to task_path(@task)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @task = Task.find(params[:id])
    @task.update(task_params)
    redirect_to task_path(@task)
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to tasks_path, status: :see_other
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :completed, :due_date, :reminder_date )
  end
end
