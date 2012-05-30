module MosaicHelper

	class Mosaic
		def initialize(path)
			#logStatus("Initializing...")
			@img = ImageList.new(path)
			@pixels = []
			@cache = {}
			#logStatus("Initialized.")
		end

		def findImages
			#logStatus("Finding images...")
			for row in (0...@img.rows)
				@pixels << []

				for col in (0...@img.columns)
					@pixels[row][col] = findColor(@img.pixel_color(col, row))
				end
			end
			#logStatus("Images Found")
		end

		def findColor(px)
			color = [px.red % 256, px.green % 256, px.blue % 256]

			img = false
			i = 0

			choice = hexFromRGB(color[0], color[1], color[2])

			if(@cache.has_key?(choice))
				cache = @cache[choice]
			else
				img = Colors.find_by_id(choice.hex)#Eager loading... Not sure if necessary. Test at some point?

				if(img != nil)
					cache = img.url
				else
					cache = closestColor(color[0], color[1], color[2])
				end

				@cache[choice] = cache
			end
			
			return cache
			#return "http://farm6.staticflickr.com/5460/7165890216_80dd2e2df8_s.jpg"#img.url
		end

		def closestColor(r, g, b)
			puts r.to_s << g.to_s << b.to_s
			range = (-3..3)
			matches = []
			for dr in range
				for dg in range
					for db in range
						test = hexFromRGB(r + dr, g + dg, b + db)
						img = Colors.find_by_id(test.hex)

						if(img != nil)
							matches << img
						end
					end
				end
			end

			min = 76#max distance is range**2 * 3, then add 1
			minUrl = hexFromRGB(r, g, b)
			for match in matches
				color = splitRGBFromHex(match.id)
				distSq = (r - color[0])**2 + (g - color[1])**2 + (b - color[2])**2
				if(min > distSq)
					min = distSq
					minUrl = match.url
				end
			end

			return minUrl
		end

		def splitRGBFromHex(color)
			color = color.to_s(16).rjust(6,'0')
			return [color[0,2].hex, color[2,2].hex, color[4,2].hex]
		end

		def hexFromRGB(r, g, b)
			return r.to_s(16).rjust(2,'0') << g.to_s(16).rjust(2,'0') << b.to_s(16).rjust(2,'0')
		end

		def display
			width = @img.columns * 10
			height = @img.rows * 10
			display = "<div style=\"width:#{width}px;height:#{height}px;\">"
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