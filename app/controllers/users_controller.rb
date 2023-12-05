class UsersController < ApplicationController
  def feed
    @followed = current_user.followeds.includes(:achievements)
  end

  def achievements
    @achievements = current_user.achievements
  end

  def connect
    @follow = Follow.new
    @not_following = User.where.not(id: current_user.id).where.not(id: current_user.followeds.pluck(:id))
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
    params.require(:follow).permit(:followed_id)
  end
end
