class MosaicController < ApplicationController
	def create
		@mosaic = MosaicHelper::Mosaic.new("http://farm6.staticflickr.com/5460/7165890216_80dd2e2df8_s.jpg")
		@mosaic.findImages
	end
end
