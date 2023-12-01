class UsersController < ApplicationController
  def feed
    @followed = Follow.where(follower_id: current_user)
  end

  def connect
    @follow = Follow.new
    @other_users = User.where.not(id: params[:id])
  end

  def build_connection
    follow = Follow.new(follow_params)
    follow.follower = current_user
    follow.save
    # if followed.save
    #   redirect_to connect_user_path(current_user)
    # else
    #   render :connect, status: :unprocessable_entity
    # end
  end

  private

  def follow_params
    params.require(:follow).permit(:followed_id)
  end
end
