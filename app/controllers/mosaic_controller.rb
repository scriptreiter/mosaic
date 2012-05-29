require 'RMagick'
include Magick

class MosaicController < ApplicationController
	def create
		#File.open("#{Rails.root}/log/create.log", "a") do |f|
		#		f.puts("test...")
		#end
		@mosaic = MosaicHelper::Mosaic.new(params[:url])
		@mosaic.findImages
	end

	def portal
	end
end
