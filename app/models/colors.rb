class Colors < ActiveRecord::Base
  attr_accessible :url
  validates_uniqueness_of :id
end
