class AnnouncementsController < ApplicationController
  respond_to :html

  # GET /announcements
  def index
    @announcements = current_user_is_admin? \
      ? Announcement.order(:created_at).reverse_order \
      : Announcement.published.order(:published_at).reverse_order
    respond_with(@announcements)
  end

  # GET /announcements/1
  def show
    scope = Announcement
    scope = scope.published unless current_user_is_admin?
    @announcement = scope.find(params[:id])
    respond_with(@announcement)
  end

  # POST /announcements/clear
  def clear
    current_user.news_delivered! if user_signed_in?
    redirect_to(announcements_path)
  end
end
