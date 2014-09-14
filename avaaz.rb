#last minute panic prototype: makes a KML file out of Avaaz
require 'open-uri'
require 'json'
require 'csv'

require 'ruby_kml'
require 'nokogiri'


urls = []
10.upto(250) { |i| urls << "http://avaaz.org/fr/event/climate/Marche_Pour_le_Climat_#{i}" }
960.upto(1293) { |i| urls << "https://secure.avaaz.org/en/event/climate/Peoples_Climate_March_#{i}" }
100.upto(160) { |i| urls << "https://secure.avaaz.org/de/event/climate/KlimaAktionstag_#{i}"}


kml = KMLFile.new

folder = KML::Folder.new(:name => 'Climate Marches')
folder.features = urls.map do |url|
    puts url

    doc = Nokogiri::HTML(open(url))
    begin
        gmaps_link = doc.at_css('.event-content_map a.pull-left')['href']
        lat, lng = gmaps_link.split('?daddr=').last.split(',').map(&:to_f)
        content = doc.at_css('.event-content')
        description = content.css('h2, p').map { |elem| elem.text }.join("\n")
        puts [lat, lng].to_s
        puts description
    rescue
        puts :FAILED!
    end

    KML::Placemark.new(
           :name => "Climate March",
           :geometry => KML::Point.new(:coordinates => {:lat => lat, :lng => lng}),
           :description => description
    )
end

kml.objects << folder


File.write('avaaz.kml', kml.render)
