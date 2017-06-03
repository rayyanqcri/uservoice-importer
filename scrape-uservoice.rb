#!/usr/bin/env ruby

require 'uservoice-ruby'
require 'rayyan-formats-core'
require 'rayyan-formats-plugins'
require 'dotenv'


Dotenv.load

RayyanFormats::Base.plugins = RayyanFormats::Base.available_plugins

plugin = RayyanFormats::Base.get_export_plugin('ris')

SUBDOMAIN_NAME = 'rayyan'
API_KEY = ENV['USERVOICE_API_KEY']
API_SECRET = ENV['USERVOICE_API_SECRET']

client = UserVoice::Client.new(SUBDOMAIN_NAME, API_KEY, API_SECRET)


tickets = client.get_collection("/api/v1/tickets.json", :limit => 50) #change the number to the amount of tickets you want per execution
# puts "Total tickets: #{tickets.size}" 

tickets.each do |ticket|
	target = RayyanFormats::Target.new
	target.sid = ticket['ticket_number'] 
	target.title = ticket['subject']
	target.date_array = []
	d = DateTime.strptime(ticket['created_at'], "%Y/%m/%d")
	target.date_array << d.year 
	target.date_array << d.month
	target.date_array << d.day  
	target.authors, target.abstracts = [], []
    messages = ticket['messages']
    messages.each do |message|    
		target.authors << message['sender']['name']
    	target.abstracts << message['body']
    end

   puts plugin.export(target)
 end

