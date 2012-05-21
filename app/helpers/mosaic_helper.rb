module MosaicHelper

	class Mosaic
		def initialize(path)
			logStatus("Initializing...")
			@img = ImageList.new(path)
			@pixels = []
			logStatus("Initialized.")
		end

		def findImages
			logStatus("Finding images...")
			for row in (0...@img.rows)
				@pixels << []

				for col in (0...@img.columns)
					@pixels[row][col] = findColor(@img.pixel_color(col, row))
				end
			end
			logStatus("Images Found")
		end

		def findColor(px)
			color = [px.red % 256, px.green % 256, px.blue % 256]

			img = false
			i = 0

			#while(!img)
				choice = hexFromRGB(color[0], color[1], color[2])
				img = Colors.find_by_id(choice.hex)#Eager loading... Not sure if necessary. Test at some point?

			#end
			if(img != nil)
				return img.url
			end
			
			return choice

			#return "http://farm6.staticflickr.com/5460/7165890216_80dd2e2df8_s.jpg"#img.url
		end

		def hexFromRGB(r, g, b)
			return r.to_s(16).rjust(2,'0') << g.to_s(16).rjust(2,'0') << b.to_s(16).rjust(2,'0')
		end

		def display
			display = "<div style=\"width:750px;height:750px;\">"
			for row in (0...@img.rows)
				for col in (0...@img.columns)
					px = @pixels[row][col]
					if(px.index('http') != nil)
						display << "<img src=\"#{px}\" width=\"10\" height=\"10\" style=\"float:left\" />"
					else
						display << "<div style=\"background:\##{px};width:10px;height:10px;float:left;\"></div>"
					end		
				end
			end
			return display << "</div>"
		end

		def logStatus(status)
			File.open("#{Rails.root}/log/create.log", "a") do |f|
				f.puts(status)
			end
		end
	end
end