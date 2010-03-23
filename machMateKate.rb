#!/usr/bin/ruby

# We use REXML
require "rexml/document"

# Some global parameters
$nodeURL="http://www.informationfreeway.org/api/0.6/node[club-mate=yes]"
$nodefile="matenodes.xml"
$matekate_txt="matekate.txt"
#$wayURL="http://www.informationfreeway.org/api/0.6/way[club-mate=yes]"

# Open the output file, truncate it
#File.open($matekate_txt, "wb")



#############################
# Find nodes
#############################

# get nodes via wget (max. 3 tries)
`wget "#{$nodeURL}" -t 3 -O #{$nodefile}`
if $? != 0
    puts("Error downloading matenodes.")
    exit 1
end

# Read the XML document
matenodes_xml = File.new($nodefile)
doc = REXML::Document.new(matenodes_xml)
matenodes_xml.close()

# Put header
print("lat\tlon\ttitle\tdescription\ticon\ticonSize\ticonOffset\n")

# For each node:
doc.elements.each("osm/node") do | node |

    title,street,housenumber,postcode,city=nil
    
    # Collect the data from the node
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
    
    # Print position
    print(node.attributes["lat"] + "\t")
    print(node.attributes["lon"] + "\t")

    # Print title
    if title != nil
	print(title + "\t")
    else
	print("Mate-Zugangspunkt\t")
    end

    # Put address to description
    description = ""
    description += street + " " if street
    description += housenumber if housenumber
    description += "<br/>" if description != ""
    description += postcode + " " if postcode
    description += city if city
    if description != ""
	print(description + "\t")
    else
	print("(no address in database)\t")
    end

    # put icon information
    print("http://www.cccmz.de/matekate/mate_icon_24.png\t24,24\t-12,-12")

    # Next node
    print("\n")
end

