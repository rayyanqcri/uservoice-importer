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

tickets = client.get_collection("/api/v1/tickets.json", limit: 10)
$stderr.puts "Total number of tickets: #{tickets.size}"

tickets.each do |ticket|
  target = RayyanFormats::Target.new
  target.sid = ticket['ticket_number']
  target.title = ticket['subject']
  date = DateTime.strptime(ticket['created_at'], "%Y/%m/%d")
  target.date_array = [date.year, date.month, date.day]
  target.authors, target.abstracts = [], []
  messages = ticket['messages']
  messages.each do |message|
    author = message['sender']['name']
    target.authors << author
    target.abstracts << "#{author} wrote on #{date}: #{message['body']}\n-----\n"
  end
  target.authors.uniq!

  puts plugin.export(target, {include_abstracts: true})
end
