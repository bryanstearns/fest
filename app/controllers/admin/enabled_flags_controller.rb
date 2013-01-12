module Admin
  class EnabledFlagsController < ApplicationController
    before_filter :authenticate_admin!
    respond_to :html
    delegate :set_enabled_value, to: :view_context
    # PUT /admin/enabled_flags/foo
    def update
      updated = %w[site sign_in sign_up].include?(params[:id]) &&
                set_enabled_value(params[:id].to_sym, params[:value] == 'true')
      if updated
        flash[:notice] = 'Flag was successfully updated.'
      else
        flash[:alert] = 'Unable to update the flag!'
      end
      redirect_to(admin_root_path)
    end
  end
end
