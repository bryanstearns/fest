class AnnouncementsController < ApplicationController
  respond_to :html

  # GET /announcements
  def index
    @announcements = current_user_is_admin? \
      ? Announcement.all \
      : Announcement.published
    respond_with(@announcements)
  end

  # GET /announcements/1
  def show
    scope = Announcement
    scope = scope.published unless current_user_is_admin?
    @announcement = scope.find(params[:id])
    respond_with(@announcement)
  end
end
