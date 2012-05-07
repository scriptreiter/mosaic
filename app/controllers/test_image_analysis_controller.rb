require 'RMagick'
require 'json'
require 'net/http'
require 'benchmark'
include Magick

class TestImageAnalysisController < ApplicationController
  def test
		#@temp = Benchmark.realtime do
		params = "api_key=d9887d18d9d02626a29194fb14dd8acc&method=flickr.photos.getRecent&format=json&nojsoncallback=1"
		url = "http://api.flickr.com/services/rest/?#{params}"
		@test = ""
		response = Net::HTTP.get_response(URI.parse(url)).body
		response = JSON.parse(response)
		@urls = []
		@colors = []
		@temp = Benchmark.realtime do
			@colors[0] = []
			#@colors[1] = []
			#@colors[2] = []
			#@colors[3] = []
			#@colors[4] = []
			#@colors[5] = []
			for i in (0...100)
				img = response["photos"]["photo"][i]
				img_url = "http://farm#{img['farm']}.staticflickr.com/#{img['server']}/#{img['id']}_#{img['secret']}_s.jpg"
				@urls << img_url
				@colors[0] << analyzeImage(img_url)
				#@colors[1] << analyzeCommon(img_url)
				#@colors[2] << analyzeImageMagick(img_url)
				#@colors[3] << analyzeThumbnail(img_url)
				#@colors[4] << analyzeThumbnailSlow(img_url)
				#@colors[5] << analyzeThumbnailFast(img_url)


			end
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

		average = [(total[0] / img.rows).to_i, (total[1] / img.rows).to_i, (total[2] / img.rows).to_i]
	
		return "#" << average[0].to_i.to_s(16).rjust(2,'0') << average[1].to_i.to_s(16).rjust(2,'0') << average[2].to_i.to_s(16).rjust(2,'0')
	end

	def analyzeHSL(file)
		img = ImageList.new(file)
		total = [0,0,0]
		for i in (1..img.rows)
			row = [0,0,0]
			for j in (1..img.columns)
				px = img.pixel_color(i - 1, j - 1)
				r = px.red % 256
				g = px.green % 256
				b = px.blue % 256
			end
		end
	end
	def analyzeCommon(file)
		img = ImageList.new(file)
		range = 50
		colors = {}

		for i in (0...img.rows)
			for j in (0...img.columns)
				color = {}
				px = img.pixel_color(i,j)
				color['r'] = px.red % 256
				color['g'] = px.green % 256
				color['b'] = px.blue % 256
				
				#Adjust based on range
				r = (color['r'] / range).to_i
				g = (color['g'] / range).to_i
				b = (color['b'] / range).to_i
				if(!colors["#{r},#{g},#{b}"])
					colors["#{r},#{g},#{b}"] = {}
				end

				if(!colors["#{r},#{g},#{b}"]["#{color['r']},#{color['g']},#{color['g']}"])
					colors["#{r},#{g},#{b}"]["#{color['r']},#{color['g']},#{color['g']}"] = 0
				end

				colors["#{r},#{g},#{b}"]["#{color['r']},#{color['g']},#{color['g']}"] += 1
			end
		end
		max_color = 'test'
		colors.each do |colorRange, colorsInRange|
			max = 0
			rangeCount = 0
			max_i = 0
			temp_max = 0
			colorsInRange.each do |color, colorCount|
				rangeCount += colorCount
				if(colorCount > max_i)
					max_i = colorCount
					temp_max = color
				end
			end
			if(rangeCount > max)
				max = rangeCount
				max_color = temp_max
			end
		end
		color = max_color.split(',')
		return "#" << color[0].to_i.to_s(16).rjust(2,'0') << color[1].to_i.to_s(16).rjust(2,'0') << color[2].to_i.to_s(16).rjust(2,'0')
	end

	def analyzeImageMagick(file)
		img = ImageList.new(file)
		img = img.quantize(1, RGBColorspace, NoDitherMethod, 0, false)
		img = img.unique_colors
		#bright_image = img.modulate(1.25, 2, 1)
		#dark_image = img.modulate(0.8, 1, 1)
		color = img.pixel_color(0,0)
		r = color.red % 256
		g = color.green % 256
		b = color.blue % 256
		return "#" << r.to_i.to_s(16).rjust(2,'0') << g.to_i.to_s(16).rjust(2,'0') << b.to_i.to_s(16).rjust(2,'0')
	end
	def analyzeThumbnail(file)
		img = ImageList.new(file)
		img = img.thumbnail(1,1)
		color = img.pixel_color(0,0)
		r = color.red % 256
		g = color.green % 256
		b = color.blue % 256
		return "#" << r.to_i.to_s(16).rjust(2,'0') << g.to_i.to_s(16).rjust(2,'0') << b.to_i.to_s(16).rjust(2,'0')
	end
	def analyzeThumbnailFast(file)
		img = ImageList.new(file)
		img.resize!(1,1,BlackmanFilter)
		color = img.pixel_color(0,0)
		r = color.red % 256
		g = color.green % 256
		b = color.blue % 256
		return "#" << r.to_i.to_s(16).rjust(2,'0') << g.to_i.to_s(16).rjust(2,'0') << b.to_i.to_s(16).rjust(2,'0')
	end
	def analyzeThumbnailSlow(file)
		img = ImageList.new(file)
		img.resize!(1,1) #TriangleFilter
		color = img.pixel_color(0,0)
		r = color.red % 256
		g = color.green % 256
		b = color.blue % 256
		return "#" << r.to_i.to_s(16).rjust(2,'0') << g.to_i.to_s(16).rjust(2,'0') << b.to_i.to_s(16).rjust(2,'0')
	end
end
