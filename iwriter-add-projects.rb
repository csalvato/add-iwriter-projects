puts "Starting Script..."
start_time = Time.now

require 'csv'
require 'builder'
require 'rest_client'
require 'open-uri'

def add_article_xml (user_data, article_data)
  func_name = "add_project"
  xml = Builder::XmlMarkup.new( :indent => 2 )
  xml.instruct! :xml, :encoding => "ASCII"
  xml.request do
    xml.user_id user_data[:user_id]
    xml.api_key user_data[:api_key]
    xml.func_name func_name
    xml.title article_data[:title]
    xml.category article_data[:category]
    xml.art_len article_data[:art_len]
    xml.submit_tier article_data[:submit_tier]
    xml.price_per article_data[:price_per]
    xml.keywords do |keywords|
      keywords.keyword article_data[:keywords]
    end
    # xml.keywords do |keywords|
    #    kw_array = article_data[:keywords].split(',')
    #    kw_array.each do |keyword| 
    #     keyword.strip!
    #     keywords.keyword keyword
    #   end
    # end
    xml.writing_style article_data[:writing_style]
    xml.art_purpose article_data[:art_purpose]
    # Untested that this CDATA works for maintaining whitespace.  Must try later.
    xml.special_instructions do 
      xml.cdata! article_data[:special_instructions]
    end
    xml.to_writers article_data[:to_writers]
    xml.wait_period article_data[:wait_period]
  end
end

def process_projects_csv (user_data, file_path)
  puts "Starting to read CSV..."
  CSV.foreach(file_path, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
    article_data = { title: row["Project Title"],
                     category: row["Category"],
                     art_len: row["Article Length"],
                     submit_tier: row["Submit Tier"],
                     price_per: row["Price Per"],
                     keywords: row["Keywords"],
                     writing_style: row["Tone"],
                     art_purpose: row["Article Purpose"],
                     special_instructions: process_special_instructions(row["Special Instructions Full"]),
                     to_writers: row["To Writers"],
                     wait_period: row["Wait Period"],
                }
    xml_request = add_article_xml(user_data, article_data)
    puts xml_request
    puts
    puts
    #response = RestClient.post "http://www.iwriter.com/api/", xml_request
    #puts response
    puts "Proceed?  Press CTRL+C to stop or anything else to go on..."
    gets.chomp
  end

end

def process_special_instructions (special_instructions)
  special_instructions.gsub! '\n', 10.chr
end

file_path = "/Users/csalvato/Development/Libraries and Utilities/ruby-add-iwriter-projects/iwriter-articles.csv"

user_data = { user_id: "csalvato",
              api_key: "YzJmMTk5YzEyOGIwNjk1MjIxNTM4Nz"
            }

process_projects_csv(user_data, file_path)

puts "Script Complete!"
puts "Time elapsed: #{Time.now - start_time} seconds"