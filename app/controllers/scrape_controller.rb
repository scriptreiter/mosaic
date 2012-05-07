require 'RMagick'
require 'json'
require 'net/http'
require 'benchmark'
include Magick

class ScrapeController < ApplicationController
  def flickr
  	
  	#Flick API REST request information
  	params = "api_key=d9887d18d9d02626a29194fb14dd8acc&method=flickr.photos.getRecent&format=json&nojsoncallback=1"
	url = "http://api.flickr.com/services/rest/?#{params}"
	
	#Send Flickr REST request and parse JSON
	response = Net::HTTP.get_response(URI.parse(url)).body
	response = JSON.parse(response)

	#Loop through the response images
	@urls = []
	@colors = []

	if(!response["stat"] == 'ok')
		puts("ERROR: Flickr Response Not Valid\n")
	end

	for i in (0...100)
		img = response["photos"]["photo"][i]
		img_url = "http://farm#{img['farm']}.staticflickr.com/#{img['server']}/#{img['id']}_#{img['secret']}_s.jpg"
		
		@urls << img_url
		@colors << analyzeImage(img_url)
	end
  end
  def analyzeImage(file)
	img = ImageList.new(file)
	total = [0,0,0]
	for i in (1..img.columns)
		row = [0,0,0]	
		for j in (1..img.rows)
			px = img.pixel_color(i - 1, j - 1)
			row[0] += px.red % 256
			row[1] += px.green % 256
			row[2] += px.blue % 256
		end
		total[0] += (row[0] / img.rows)
		total[1] += (row[1] / img.rows)
		total[2] += (row[2] / img.rows)
	end

	average = [total[0] / img.rows, total[1] / img.rows, total[2] / img.rows]
	
	return "#" << average[0].to_i.to_s(16).rjust(2,'0') << average[1].to_i.to_s(16).rjust(2,'0') << average[2].to_i.to_s(16).rjust(2,'0')
  end
end