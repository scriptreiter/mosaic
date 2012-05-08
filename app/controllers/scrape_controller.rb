require 'RMagick'
require 'json'
require 'net/http'
require 'benchmark'
include Magick

class ScrapeController < ApplicationController
  def flickr
  	request = FlickrRequest.new("flickr.photos.getRecent")
  	request.send
  	request.process

  	@colors = request.getAnalyzedColors
  	@urls = request.getAnalyzedURLs
  end
end