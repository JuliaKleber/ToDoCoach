class TaskInvitationsController < ApplicationController
  def destroy
    task_invitation = TaskInvitation.find(params[:id])
    if task_invitation.destroy
      redirect_to feed_user_path, notice: "You were not added to the task!"
    else
      render :feed, notice: "This request could not be processed!"
    end
  end
end
