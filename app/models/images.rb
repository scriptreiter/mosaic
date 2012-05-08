class Images < ActiveRecord::Base
  attr_accessible :color, :url
  validates_uniqueness_of :color, :url
end
