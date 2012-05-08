class Images < ActiveRecord::Base
  attr_accessible :color, :url
  validates_uniqueness_of :color#add in later taking it out now for speed, :url
end
