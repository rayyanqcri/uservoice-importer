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

tickets = client.get_collection("/api/v1/tickets.json?page=1&per_page=2")
tickets.each do |ticket|
	target = RayyanFormats::Target.new
	target.sid = ticket['ticket_number'] 
	target.title = ticket['subject']
  # continue extracting fields, check https://github.com/rayyanqcri/rayyan-formats-plugins/blob/master/lib/rayyan-formats-plugins/plugins/endnote.rb

  messages = ticket['messages']
	#puts "Ticket: \"#{ticket['ticket_number']}\", Subject: #{ticket['subject']}, Messages: #{messages.length}"
  messages.each do |message|
    #puts "Message from '#{message['sender']['name']}': #{message['body']}"
  end
  # remove the puts

  puts plugin.export(target)
end

