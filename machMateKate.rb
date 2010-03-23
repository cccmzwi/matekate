#!/usr/bin/ruby

# We use REXML
require "rexml/document"

matefile="matekate.txt"
nodeURL="http://www.informationfreeway.org/api/0.6/node[club-mate=yes]"
#wayURL="http://www.informationfreeway.org/api/0.6/way[club-mate=yes]"

# get nodes, wget prints to stdout and we read that
matenodes_xml=`wget "#{nodeURL}" -t 3 -O -`
#matenodes_xml=`cat matenodes.xml`
if $? != 0
    puts("Error downloading matenodes.")
    exit 1
end

doc = REXML::Document.new(matenodes_xml)

print("lat\tlon\ttitle\tdescription\ticon\ticonSize\ticonOffset\n")

doc.elements.each("osm/node") do | node |
    title,street,housenumber,postcode,city=nil
    node.each do | tag |
        if tag.class == REXML::Element
	    key=tag.attributes["k"]
	    value=tag.attributes["v"]
	    
	    case key
	    when "name"
		title=value
	    when "addr:street"
		street=value
	    when "addr:housenumber"
		housenumber=value
	    when "addr:postcode"
		postcode=value
	    when "addr:city"
		city=value
	    end
        end
    end
    
    # Position
    print(node.attributes["lat"] + "\t")
    print(node.attributes["lon"] + "\t")

    # Title
    if title != nil
	print(title + "\t")
    else
	print("\n")
    end

    # Put address to description
    description = ""
    description += street + " " if street
    description += housenumber if housenumber
    description += "<br/>" if description != ""
    description += postcode + " " if postcode
    description += city if city
    print(description) if description
    print("\t")

    # put icon information
    print("http://www.cccmz.de/matekate/mate_icon_24.png\t24,24\t-12,-12")

    # Next node
    print("\n")
end

#if (! wget "$nodeURL" -t 3 -O matenodes.osm.part)
#then
#    echo "getting data from server failed (nodes)."
#    rm -f matenodes.osm.part
#    exit 1
#else
#    mv matenodes.osm.part matenodes.osm
#fi
#xsltproc osm2text.xsl matenodes.osm | sed 's/^\s\s//g' > "$matefile.part"
