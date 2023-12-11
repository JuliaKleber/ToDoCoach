class UsersController < ApplicationController
  def feed
    @invitations = current_user.task_invitations
    @followed = current_user.followeds.includes(achievements: :user_achievements)
    @congrats = current_user.user_achievement_congratulations
  end

  def achievements
    @achievements = current_user.achievements
  end

  def congratulate
    congrat = UserAchievementCongratulation.new(
      user_id: params[:id],
      follower_id: current_user.id,
      achievement_id: params[:format],
      date: Time.now.to_date
    )
    if congrat.save
      # ReminderJob.set(wait_until: @task.reminder_date).perform_later(@task) if @task.reminder_date != null
      flash[:notice] = "You congratulated #{User.find(params[:id]).user_name}"
      redirect_to feed_user_path(current_user)
    else
      render :feed, status: :unprocessable_entity
    end
  end

  def connect
    @follow = Follow.new
    if params[:query].present?
      @not_following = User.where.not(id: current_user.id).where.not(id: current_user.followeds.pluck(:id)).search_by_username_and_email(params[:query])
    else
      @not_following = User.where.not(id: current_user.id).where.not(id: current_user.followeds.pluck(:id))
    end
  end

  def build_connection
    follow = Follow.new(follow_params)
    follow.follower = current_user
    if follow.save
      flash[:notice] = "You are now following #{follow.followed.user_name}"
      redirect_to connect_user_path(current_user)
    else
      render :connect, status: :unprocessable_entity
    end
  end

  def disconnect
    @following = User.where.not(id: current_user.id).where(id: current_user.followeds.pluck(:id))
    render :disconnect, locals: { follow: @following }
  end

  def destroy_connection
    follow = Follow.where(followed_id: params[:user][:followed_id].to_i).where(follower_id: current_user.id).first
    if follow.destroy
      flash[:notice] = "You are not following #{follow.followed.user_name} anymore"
      redirect_to disconnect_user_path(current_user)
    else
      render :disconnect, status: :unprocessable_entity
    end
  end

  private

  def follow_params
    params.require(:follow).permit(:followed_id, :search)
  end
end
