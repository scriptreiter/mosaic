module ScrapeHelper

	class FlickrRequest
		def initialize(src)
			params = "api_key=d9887d18d9d02626a29194fb14dd8acc&method=#{src}&format=json&nojsoncallback=1&per_page=500"
			@url = "http://api.flickr.com/services/rest/?#{params}"
		end

		def send
			#Send Flickr REST request and parse JSON
			@response = JSON.parse(Net::HTTP.get_response(URI.parse(@url)).body)

			if(!@response["stat"] == 'ok')
				processError
			end
		end

		def processError
			puts("ERROR: Flickr Response Not Valid\n")
		end

		def process
			@urls = []
			@colors = []

			duplicates = 0
			for i in (0...500)
				img = @response["photos"]["photo"][i]
				img_url = "http://farm#{img['farm']}.staticflickr.com/#{img['server']}/#{img['id']}_#{img['secret']}_s.jpg"
				color = analyzeImage(img_url)


				#Add to database
				@Image = Images.new
				@Image.color = color
				@Image.url = img_url

				if(@Image.save)
					@urls << img_url
					@colors << color
				else
					duplicates += 1
				end
			end
			
			File.open("#{Rails.root}/log/test.log", "a") do |f|
				f.write(((500 - duplicates) / 5).to_s << "%\n")
				f.write(Images.count.to_s << "\n")
			end
			puts ((500 - duplicates) / 5).to_s << "%"
			puts Images.count
		end

		def getAnalyzedColors
			return @colors
		end

		def getAnalyzedURLs
			return @urls
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
			
			return average[0].to_i.to_s(16).rjust(2,'0') << average[1].to_i.to_s(16).rjust(2,'0') << average[2].to_i.to_s(16).rjust(2,'0')
		end
	end
end