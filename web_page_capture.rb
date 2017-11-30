#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'csv'
require 'capybara/poltergeist'

@in_file = ARGV[0]
@out_file = ARGV[1]
@save_path = ARGV[2]

# register Driver
def register_Driver
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new( app, {
      debug: false,  # turn on poltergeist debug mode
      js: true,
      js_errors: false,  # turn on javascript errors on page
      timeout:   30,
      phantomjs_options: ['--load-images=yes', '--ignore-ssl-errors=yes', '--ssl-protocol=any'],
      inspector: true,
      phantomjs_logger: File.open(File::NULL, 'w')
    })
  end

  Capybara.javascript_driver = :poltergeist
  Capybara.current_driver    = :poltergeist
  Capybara.default_max_wait_time = 5
  Capybara.run_server = false
end

# start capture web page
def captureWebPage(row)
  page = Capybara.current_session
  begin
    print "[+] Connecting to #{row[0]}:#{row[1]} "
    if ['443'].include? row[1]
      page.visit("https://#{row[0].strip}:#{row[1].strip}")
    else
      page.visit("http://#{row[0].strip}:#{row[1].strip}")
    end
    page.save_screenshot("#{@save_path}#{row[0]}:#{row[1]}.png", full: false)
    puts "... successfully capture web page"
    status = true
  rescue
    puts "... error connecting!"
    status = false
  ensure
    page.reset_session!
  end
  return status
end

# read input file
def readCSVFile(file)
  @result = CSV.open(@out_file, "wb")
  options = { headers: true }
  CSV.foreach(file, options) do |row|
    @result << row if captureWebPage(row)
  end
  @result.close
end

register_Driver
readCSVFile(@in_file)
