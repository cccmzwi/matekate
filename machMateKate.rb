#!/usr/bin/ruby

# Author: Tanjeff Moos <tanjeff@cccmz.de>
# Date: 25.03.2010
# For the Chaos Computer Club Mainz e.V.
#
# This script is licensed under the GPL.
# TODO: Add GPL notice here ;-)
#


# This script downloads data from the OpenStreetMap database and 
# converts it to a format suitable for the OpenLayers API.
#
# Data is downloaded via 'wget', requesting all nodes which are tagged 
# with certain tags. The resulting files are in XML format.  They are 
# parsed and text files are constructed which are feeded into an 
# OpenLayers JavaScript program to serve as overlays which makes 
# club-mate locations visible.


# We use REXML
require "rexml/document"

# Whether to download data or use files which were downloaded before
$do_download = true

# URLs and file names
$URL_club_mate="http://www.informationfreeway.org/api/0.6/node[club-mate=yes]"
$XML_club_mate="club-mate.xml"
$TXT_club_mate="club-mate.txt"

$URL_drink_club_mate="http://www.informationfreeway.org/api/0.6/node[drink:club-mate=yes]"
$XML_drink_club_mate="drink_club-mate.xml"
$TXT_drink_club_mate="drink_club-mate.txt"

# Global matenode counter
$count = 0


########################
# tag: club-mate=yes
########################

# Download data (max. 3 tries)
if $do_download
    `wget "#{$URL_club_mate}" -t 3 -O #{$XML_club_mate}`
    if $? != 0
	puts("Error downloading matenodes.")
	exit 1
    end
end

# Open the text file to be written
outfile = File.new($TXT_club_mate, File::WRONLY|File::CREAT|File::TRUNC)

# Put header
outfile << "lat\tlon\ttitle\tdescription\ticon\ticonSize\ticonOffset\n"

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
    outfile << node.attributes["lat"] + "\t"
    outfile << node.attributes["lon"] + "\t"

    # Print title (use name tag if it was found)
    if name != nil
	outfile << name + "\t"
    else
	outfile << "Mate-Zugangspunkt\t"
    end

    # Build address from tags
    description = ""
    description += street + " " if street
    description += housenumber if housenumber
    description += "<br/>" if description != ""
    description += postcode + " " if postcode
    description += city if city
    description = "(no address in database)" if description == ""
    
    # Add Note about obsolete tag
    description += "<br/>" if description != ""
    description += "<br/>NOTE:<br/>"
    description += "The tag club-mate=yes is obsolete. Use drink:club-mate=* instead."

    # Put description to file
    outfile << description + "\t"

    # put icon information
    outfile << "./icon_club-mate-obsolet_37x37_-12x-25.png\t37,37\t-12,-25"

    # Next node
    outfile << "\n"
    $count += 1
end


###########################
# tag: drink:club-mate=*
###########################

# Download data (max. 3 tries)
if $do_download
    `wget "#{$URL_drink_club_mate}" -t 3 -O #{$XML_drink_club_mate}`
    if $? != 0
	puts("Error downloading matenodes.")
	exit 1
    end
end

# Open the text file to be written
outfile = File.new($TXT_drink_club_mate, File::WRONLY|File::CREAT|File::TRUNC)

# Put header
outfile << "lat\tlon\ttitle\tdescription\ticon\ticonSize\ticonOffset\n"

# Parse the XML file
doc = REXML::Document.new(File.new($XML_drink_club_mate))

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
    outfile << node.attributes["lat"] + "\t"
    outfile << node.attributes["lon"] + "\t"

    # Print title (use name tag if it was found)
    if name != nil
	outfile << name + "\t"
    else
	outfile << "Mate-Zugangspunkt\t"
    end

    # Build address from tags
    description = ""
    description += street + " " if street
    description += housenumber if housenumber
    description += "<br/>" if description != ""
    description += postcode + " " if postcode
    description += city if city
    if description != ""
	outfile << description + "\t"
    else
	outfile << "(no address in database)\t"
    end

    # put icon information
    outfile << "./icon_club-mate_24x24_-12x-12.png\t24,24\t-12,-12"

    # Next node
    outfile << "\n"
    $count += 1
end


###########################
# Statistics (hacky)
###########################

# TODO: find more elegant solution

outfile = File.new("matecount.html", File::WRONLY|File::CREAT|File::TRUNC)

outfile << "<p>"
outfile << "Derzeit sind #{$count} Mate-Zugangspunkte eingetragen. "
outfile << "Stand: " + Time.now.asctime()
outfile << "</p>"

outfile.close()
