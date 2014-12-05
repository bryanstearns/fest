class FestivalLocation < ActiveRecord::Base
  belongs_to :festival
  belongs_to :location
end
