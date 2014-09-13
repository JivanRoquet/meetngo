require 'open-uri'
require 'nokogiri'
require 'json'
require 'csv'


def greenpeace_uk
    events = []
    doc = Nokogiri::HTML(open('http://www.greenpeace.org.uk/groups/all/events'))

    last_page = doc.at_css('.pager-last > a')['href'].split('events?page=').last.to_i
    puts "Greenpeace UK: #{last_page + 1} pages"

    0.upto(last_page) do |page|
        url = "http://www.greenpeace.org.uk/groups/all/events?page=#{page}"
        doc = Nokogiri::HTML(open(url))
        puts "Greenpeace UK: page #{page + 1}"
        doc.css('.view-content>div').each do |div|
            event = {}
            link = div.at_css('.title-1 a')
            next unless link
            location_link = div.at_css('.title a')
            puts "Greenpeace UK: #{link.text}"

            events << {
                organisation: "Greenpeace UK",
                source: url,
                title: link.text,
                link:  URI.join('http://www.greenpeace.org.uk/', link['href']).to_s,
                location:  location_link ? location_link.text + ", United Kingdom" : "United Kingdom",
                start_date: Date.parse(div.at_css('date-display-single').text.split('-').first).strftime("%m%d%Y"),
                end_date: Date.parse(div.at_css('date-display-single').text.split('-').first).strftime("%m%d%Y"), #too lazy sorry
                description: div.at_css('.field-body-value').text
            }
        end
    end

    events
end


def greenpeace_us
    events = []
    url = 'https://greenwire.greenpeace.org/usa/en/events'
    doc = Nokogiri::HTML(open(url))

    doc.css('article').map do |div|
        event = {}
        link = div.at_css('h2>a')
        next unless link
        puts "Greenpeace US: #{link.text}"

        {
            organisation: "Greenpeace US",
            source: url,
            title: link.text,
            link:  URI.join('https://greenwire.greenpeace.org/', link['href']).to_s,
            location: div.at_css('.locality').text,
            start_date: Date.parse(div.at_css('date-display-single').text.split('-').first).strftime("%m%d%Y"), #TODO
            description: div.at_css('.field-name-body .field-item').text
        }
    end
end


def org350
    url = 'https://docs.google.com/spreadsheet/pub?key=0Agcr__L1I1PDdEpoMnhxR0RHdkFsWlFtNTlEZlltR0E&single=true&gid=0&output=txt'

    CSV.parse(open(url).read, col_sep: "\t").map do |row|
        {
            organisation: "350.org",
            source: url,
            title: row[0],
            location: row[2],
            link: row[3],
            description: row[4],
            lng: row[5],
            lat: row[6]
        }
    end
end


def gouv_fr
    url = 'http://evenements.developpement-durable.gouv.fr/campagnes/evenements/list/1'

    JSON.parse(open(url).read)['evenements'].map do |event|
        doc = Nokogiri::HTML(event['content'])
        lines = doc.inner_html.split('<br />') #sooo unstable
        link = doc.at_css('a')
        {
            organisation: "",
            source: url,
            title: event['title'],
            location: lines[2] + ", France",
            link: URI.join('http://evenements.developpement-durable.gouv.fr/', link['href']).to_s,
            description: '',
            lng: event["longitude"],
            lat: event["latitude"]
        }
    end
end


events = []
events |= greenspeas_uk rescue puts "CAN NO LONGER CRAWL GREENSPEACE UK"
events |= org350 rescue puts "CAN'T FIND 350.org SPREADSHEET" #could email you
events |= gouv_fr rescue puts "CAN NO LONGER CRAWL GOUV FR"


events.foreach do |event|
    unless event[:lng]
        #geocode, bitch
    end

    event[:hash] = Digest::MD5.hexdigest(event[:source] + event[:title])
end
        

File.write('events.json', events.to_json)
