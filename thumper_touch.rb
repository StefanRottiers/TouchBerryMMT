#!/usr/bin/env ruby

require 'listen'
require 'net/http'
require 'json'

class ThumperRestInterface

	@@DRIVE_SPEED = 70
	@@ID = 'BadBois'

	def initialize host='http://localhost:3000'
		@host = host
	end
	
	def alarm
		uri = URI(@host + '/alarm')
                req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
                req.body = {action:"toggle", id: @@ID }.to_json
                send_request uri, req
		strobe
	end

	def strobe
		uri = URI(@host + '/neopixels/effects/strobe/0')
		req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
		req.body = {red: 250, green: 100, blue:0, delay: 100, id: @@ID }.to_json
		send_request uri, req
	end

	def dim
		uri = URI(@host + '/neopixels/strings/0')
		req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
		req.body = {red: 0, green: 0, blue: 0, id: @@ID }.to_json
		send_request uri, req
	end

	def left
		drive @@DRIVE_SPEED, -@@DRIVE_SPEED
	end

	def right
		drive -@@DRIVE_SPEED, @@DRIVE_SPEED
	end

	def forward
		drive @@DRIVE_SPEED, @@DRIVE_SPEED
	end

	def reverse
		drive -@@DRIVE_SPEED, -@@DRIVE_SPEED
	end

	def stop
		drive 0, 0
	end

	def drive leftspeed, rightspeed
		uri = URI(@host + '/speed')
		req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
		req.body = {left_speed: leftspeed, right_speed: rightspeed, id: @@ID }.to_json
		send_request uri, req
	end

	def send_request uri, req
		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
			http.request(req)
		end
	end
end

thumper = ThumperRestInterface.new ('http://10.182.34.107:3000')

listener = Listen.to('/tmp/touch') do |modified|
  puts "modified absolute path: #{modified}"
	File.readlines(modified.first).each do |instruction|
		instruction.strip!

		if thumper.respond_to?(instruction.to_sym)
			thumper.send instruction
		else
			thumper.stop
		end

	end
end
listener.start # not blocking

sleep
