class UserAchievementCongratulationsController < ApplicationController
  def destroy
    congrat = UserAchievementCongratulation.find(params[:id])
    if congrat.destroy
      redirect_to feed_user_path, notice: "The congratulation message has been deleted!"
    else
      render :feed, notice: "The request could not be processed!"
    end
  end
end
