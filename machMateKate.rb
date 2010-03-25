#!/usr/bin/ruby

# We use REXML
require "rexml/document"

# Some global parameters
$URL_club_mate="http://www.informationfreeway.org/api/0.6/node[club-mate=yes]"
$URL_drink_club_mate="http://www.informationfreeway.org/api/0.6/node[drink:club-mate=yes]"
$XML_club_mate="club-mate.xml"
$XML_drink_club_mate="drink_club-mate.xml"

$matekate_txt="matekate.txt"

# Open the output file, truncate it
#File.open($matekate_txt, "wb")

# Put header
print("lat\tlon\ttitle\tdescription\ticon\ticonSize\ticonOffset\n")



#############################
# Find nodes
#############################


# get nodes with "drink:club-mate" tag via wget (max. 3 tries)
#`wget "#{$URL_drink_club_mate}" -t 3 -O #{$nodefile}`
#if $? != 0
#    puts("Error downloading matenodes.")
#    exit 1
#end


########################
# tag: club-mate=yes
########################

# get nodes with "club-mate" tag via wget (max. 3 tries)
#`wget "#{$URL_club_mate}" -t 3 -O #{$nodefile}`
#if $? != 0
#    puts("Error downloading matenodes.")
#    exit 1
#end

# Parse the XML file
doc = REXML::Document.new(File.new($XML_club_mate))

# For each node:
doc.elements.each("osm/node") do | node |

    name,street,housenumber,postcode,city = nil
    
    # Collect needed data from the tags
    node.elements.each("tag") do | tag |
        key=tag.attributes["k"]
        value=tag.attributes["v"]
        
	case key
	when "name"
	    name=value
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
    
    # Print position
    print(node.attributes["lat"] + "\t")
    print(node.attributes["lon"] + "\t")

    # Print title (use name tag if it was found)
    if name != nil
	print(name + "\t")
    else
	print("Mate-Zugangspunkt\t")
    end

    # Build address from tags
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

