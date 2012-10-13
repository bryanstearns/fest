class Festival < ActiveRecord::Base
  attr_accessible :ends_on, :location, :main_url, :name, :public, :revised_at, :scheduled, :slug, :slug_group, :starts_on, :updates_url
end
