#!/usr/bin/env ruby

require 'rubygems'
require 'highline'
include HighLine::SystemExtensions

class Rap
  attr_accessor :slide_number, :path, :total_slides

  def initialize(path)
    @total_slides = 0
    @slide_number = 1
    @path = path
    count_slides
    puts "\e[H\e[2J"
    file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
    starting_row, last_row = self.set_terminal(file)
    starting_row.times do
      puts
    end
    file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
    file.each_line do |line|
      puts line
    end
    file.close
    last_row.times do
      puts
    end
    puts "Slide #{@slide_number}/#{@total_slides}"
  end

  def next_slide
    @slide_number = @slide_number + 1
    begin
      file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
    rescue
      @slide_number = @slide_number - 1
      return
    end
    puts "\e[H\e[2J"
    starting_row, last_row = self.set_terminal(file)
    starting_row.times do
      puts
    end
    file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
    file.each_line do |line|
      puts line
    end
    file.close
    last_row.times do
      puts
    end
    puts "Slide #{@slide_number}/#{@total_slides}"
  end

  def prev_slide
    @slide_number = @slide_number - 1
    begin
      file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
    rescue
      @slide_number = 1
      return
    end
    puts "\e[H\e[2J"
    starting_row, last_row = self.set_terminal(file)
    starting_row.times do
      puts
    end
    file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
    file.each_line do |line|
      puts line
    end
    file.close
    last_row.times do
      puts
    end
    puts "Slide #{@slide_number}/#{@total_slides}"
  end

  def count_slides
    begin
      slides = Dir.open(@path)
    rescue
      puts "Are there any valid paths?"
      exit 2
    end
    slides.entries.each { |e| @total_slides = @total_slides + 1 if e =~ /slide[0-9]*\.txt/ }
  end

  def set_terminal(file)
    file_row_count = file.lines.count
    terminal_row_count = terminal_size.last
    starting_row = (terminal_row_count / 2) - (file_row_count / 2)
    last_row = terminal_row_count - (starting_row + file_row_count)

    [starting_row, last_row]
  end
end

if ARGV[0].nil?
  puts "Can you tell me which slides to load?"
  puts "\n\t$ ruby rap.rb path_to_slides\n\n"
  exit 1
end

if ARGV[0].eql? "--help"
  puts "Okay, this is what I can tell you:"
  puts "  'n' -- next slide"
  puts "  'p' -- previous slide"
  puts "  'q' -- quit"
  exit 0
end

rap = Rap.new(ARGV[0])

loop do
  char = get_character
  if char == 110
    rap.next_slide
  elsif char == 112
    rap.prev_slide
  elsif char == 113
    exit 0
  end
end
