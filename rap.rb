#!/usr/bin/env ruby

require 'rubygems'
require 'highline'
include HighLine::SystemExtensions

class Rap
  attr_accessor :slide_number, :path, :total_slides

  def initialize(path)
    @total_slides = 0
    @slide_number = 0
    @path = path
    count_slides
    self.change_slide(1)
  end

  def change_slide(way)
    if way > 0
      @slide_number = @slide_number + 1
      begin
        file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
      rescue
        @slide_number = @slide_number - 1
        return
      end
    else
      @slide_number = @slide_number - 1
      begin
        file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
      rescue
        @slide_number = 1
        return
      end
    end
    self.clear
    starting_row, last_row, warn = self.set_terminal(file)
    starting_row.times do
      puts
    end
    file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
    starting_row, last_row, warn = self.set_terminal(file)
    # just can't figure that shit out! :/
    file.close
    file = File.open("#{@path}/slide#{@slide_number}.txt", "r")
    self.print_slide(file, starting_row)
    file.close
    self.print_slide_number(last_row, warn)
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

  def print_slide(file, starting_row)
    starting_row.times do
      puts
    end
    file.each_line do |line|
      puts line
    end
  end
  
  def print_slide_number(last_row, warn)
    last_row.times do
      puts
    end
    print "!" if warn
    puts "Slide #{@slide_number}/#{@total_slides}"
  end

  def set_terminal(file)
    file_row_count = file.lines.count
    terminal_row_count = terminal_size.last
    starting_row = (terminal_row_count / 2) - (file_row_count / 2)
    last_row = terminal_row_count - (starting_row + file_row_count)

    terminal_row_count < file_row_count ? warn = true : warn = false

    [starting_row, last_row, warn]
  end
  
  def prompt
    char = get_character
    if char == 110
      self.change_slide(1)
    elsif char == 112
      self.change_slide(-1)
    elsif char == 113
      exit 0
    end
  end
  
  def clear
    puts "\e[H\e[2J"
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
  puts
  puts "It will display a '!' before slide number\n  if the slide is bigger than screen"
  exit 0
end

rap = Rap.new(ARGV[0])

loop do
  rap.prompt
end
