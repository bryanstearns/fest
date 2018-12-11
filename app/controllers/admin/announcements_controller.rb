module Admin
  class AnnouncementsController < ApplicationController
    before_action :authenticate_admin!
    respond_to :html

    # GET /admin/announcements/new
    def new
      respond_with(:admin, @announcement = Announcement.new(published_at: Time.current))
    end

    # GET /admin/announcements/1/edit
    def edit
      respond_with(:admin, @announcement = Announcement.find(params[:id]))
    end

    # POST /admin/announcements
    def create
      @announcement = Announcement.new(announcement_params)
      if @announcement.save
        flash[:notice] = 'Announcement was successfully created.'
      end
      respond_with(:admin, @announcement, location: announcements_path)
    end

    # PATCH /admin/announcements/1
    def update
      @announcement = Announcement.find(params[:id])
      if @announcement.update_attributes(announcement_params)
        flash[:notice] = 'Announcement was successfully updated.'
      end
      respond_with(:admin, @announcement, location: announcements_path)
    end

    # DELETE /admin/announcements/1
    def destroy
      @announcement = Announcement.find(params[:id])
      @announcement.destroy
      respond_with(:admin, @announcement, location: announcements_path)
    end

  private
    def announcement_params
      params.require(:announcement).
          permit(:contents, :published, :published_at, :subject)
    end
  end
end
