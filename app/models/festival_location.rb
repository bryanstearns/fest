class FestivalLocation < ApplicationRecord
  belongs_to :festival
  belongs_to :location
end
