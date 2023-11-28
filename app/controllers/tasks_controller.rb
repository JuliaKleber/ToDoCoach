class TasksController < ApplicationController
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
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
