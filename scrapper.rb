require 'open-uri'
require 'json'
require 'csv'

require 'nokogiri'
require 'rest_client'


MAINTAINER = "Thomas Schneider <teesbase@gmail.com>"
SOURCES = %w(greenpeace_uk gouv_fr)


def greenpeace_uk
    #A few dozens events
    events = []

    doc = Nokogiri::HTML(open('http://www.greenpeace.org.uk/groups/all/events'))
    last_page = doc.at_css('.pager-last > a')['href'].split('events?page=').last.to_i
    puts "Greenpeace UK: #{last_page + 1} pages"

    0.upto(last_page) do |page|
        puts "Greenpeace UK: page #{page + 1}"
        url = "http://www.greenpeace.org.uk/groups/all/events?page=#{page}"

        doc = Nokogiri::HTML(open(url))
        doc.css('.view-content>div').each do |div|
            link = div.at_css('.title-1 a')
            next unless link
            puts "Greenpeace UK: #{link.text}"
            location_link = div.at_css('.title a')

            if single_date = div.at_css('.date-display-single')
                start_date = end_date = single_date.text
            else
                start_date = div.at_css('.date-display-start').text
                end_date = div.at_css('.date-display-end').text
            end

            events << {
                organisation: "Greenpeace UK",
                source: url,
                title: link.text,
                link:  URI.join('http://www.greenpeace.org.uk/', link['href']).to_s,
                location:  location_link ? location_link.text + ", United Kingdom" : "United Kingdom",
                start_date: start_date,
                end_date:  end_date,
                description: div.at_css('.field-body-value').text
            }
        end
    end

    events
end

=begin

def greenpeace_us
    #A dozen events
    events = []
    url = 'https://greenwire.greenpeace.org/usa/en/events'
    doc = Nokogiri::HTML(open(url))

    doc.css('article').map do |div|
        event = {}
        link = div.at_css('h2>a')
        next unless link
        puts "Greenpeace US: #{link.text}"

        if single_date = div.at_css('.date-display-single')
            start_date = end_date = single_date.text
        else
            start_date = div.at_css('.date-display-start').text
            end_date = div.at_css('.date-display-end').text
        end

        {
            organisation: "Greenpeace US",
            source: url,
            title: link.text,
            link:  URI.join('https://greenwire.greenpeace.org/', link['href']).to_s,
            location: div.at_css('.locality').text,
            start_date: start_date,
            end_date: end_date,
            description: div.at_css('.field-name-body .field-item').text.strip
        }
    end
end


def org350
    #Just lists groups
    url = 'https://docs.google.com/spreadsheet/pub?key=0Agcr__L1I1PDdEpoMnhxR0RHdkFsWlFtNTlEZlltR0E&single=true&gid=0&output=txt'

    CSV.parse(open(url).read, col_sep: "\t").map do |row|
        puts "350.org: #{row.first}"

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

=end

def gouv_fr
    #because none of the idiots in this group noticed it's April 2014 only
    url = 'http://evenements.developpement-durable.gouv.fr/campagnes/evenements/list/1'

    JSON.parse(open(url).read)['evenements'].map do |event|
        puts "evenements.developpement-durable.gouv.fr: #{event['title']}"

        doc = Nokogiri::HTML(event['content'])
        link = doc.at_css('a')
        _, dates, location = doc.inner_html.split('<br>') #too lazy to find the proper xpath way
        start_date = dates #Date.parse will only parse first date
        end_date = dates.split('au').last

        {
            organisation: "Inconnue",
            source: url,
            title: event['title'],
            location: location + ", France",
            link: URI.join('http://evenements.developpement-durable.gouv.fr/', link['href']).to_s,
            start_date: start_date,
            end_date: end_date,
            description: '',
            lng: event["longitude"],
            lat: event["latitude"]
        }
    end
end


events = []

#crawls each sources and emails maintainer if fails on one
SOURCES.each do |source|
    begin
        events |= send(source)
    rescue
        RestClient.post "https://api:key-a3aa09958212acb10c11860f49e112f6"\
        "@api.mailgun.net/v2/sandbox3ede964f239f4b95ab1194ea8659df34.mailgun.org/messages",
          from: "Mailgun Sandbox <postmaster@sandbox3ede964f239f4b95ab1194ea8659df34.mailgun.org>",
          to: MAINTAINER,
          subject: "MeetNGO scrapper: module #{source} no longer works",
          text: "Dear maintainer,\n\nmodule #{source} no longer works so please fix it or remove it for source list.\n\nThanks,\nThe MeetNGO scrapper"
    end
end


events.each do |event|
    event[:start_date] = Date.parse(event[:start_date]).strftime("%m%d%Y") if event[:start_date]
    event[:end_date] = Date.parse(event[:end_date]).strftime("%m%d%Y") if event[:end_date]

    unless event[:lng]
        response = JSON.parse(open('https://maps.googleapis.com/maps/api/geocode/json?address=' + URI.escape(event[:location])).read)
        event.merge! response["results"][0]["geometry"]["location"] unless response["results"].empty?
        sleep 0.1 #10 request/second limit
    end

    event[:hash] = Digest::MD5.hexdigest(event[:source] + event[:title])
end

File.write('meetngo/events.json', events.to_json)
