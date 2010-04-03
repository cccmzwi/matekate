#!/usr/bin/ruby

################################
# License
################################

#
# Copyright 2010
# Tanjeff Moos <tanjeff@cccmz.de>
# (Chaos Computer Club Mainz e.V.)
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


################################
# Globals
################################

# This script downloads data from the OpenStreetMap database and 
# converts it to a format suitable for the OpenLayers API.
#
# Data is downloaded via 'wget', requesting all nodes which are tagged 
# with certain tags. The resulting files are in XML format.  They are parsed 
# (using REXML) and text files are constructed which are fed into an OpenLayers 
# JavaScript program to serve as overlays which makes club-mate locations (and 
# others) visible.


# We use REXML
require "rexml/document"

# Parameter -d: no download (use existing XML files). Intended for development 
# puporse.
if (ARGV[0] == "-d")
    $do_download = false
else
    $do_download = true
end

# URLs, file names and counters
$URL_club_mate="http://www.informationfreeway.org/api/0.6/node[club-mate=yes]"
$XML_club_mate="club-mate.xml"
$TXT_club_mate="club-mate.txt"
$count_club_mate = 0;

$URL_drink_club_mate="http://www.informationfreeway.org/api/0.6/node[drink:club-mate=*]"
$XML_drink_club_mate="drink_club-mate.xml"
$TXT_drink_club_mate="drink_club-mate.txt"
$count_drink_club_mate = 0;

$URL_drink_afri_cola="http://www.informationfreeway.org/api/0.6/node[drink:afri-cola=*]"
$XML_drink_afri_cola="drink_afri-cola.xml"
$TXT_drink_afri_cola="drink_afri-cola.txt"
$count_drink_afri_cola = 0;


################################
# Helper functions
################################

# Download data (max. 3 tries)
#
# Give an URL and under which name the data shall be stored.
# The result is the file 'filename'
#
# The function exits on error!
def download(url, filename)
    if $do_download
	`wget "#{url}" -t 3 -O #{filename}`
	if $? != 0
	    puts("Error downloading matenodes.")
	    exit 1
	end
    end
end



def parse(infile, outfile, drink_tag, description_extra, icons)
    doc = REXML::Document.new(File.new(infile))
    file = File.new(outfile, File::WRONLY|File::CREAT|File::TRUNC)

    count = 0;

    # Put header
    file << "lat\tlon\ttitle\tdescription\ticon\ticonSize\ticonOffset\n"
    
    doc.elements.each("osm/node") do | node |
	name,street,housenumber,postcode,city = nil
	icon = ""

	# Collect needed data from the tags
    	node.elements.each("tag") do | tag |
    	    key=tag.attributes["k"]
    	    value=tag.attributes["v"]

    	    case key
    	    when drink_tag
		if icons.has_key?(value)
		    icon=icons[value]
		else
		    icon=icons["default"]
		end
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
    	file << node.attributes["lat"] + "\t"
    	file << node.attributes["lon"] + "\t"

    	# Print title (use name tag if it was found)
    	if name != nil
    	    file << name + "\t"
    	else
    	    file << "Mate-Zugangspunkt\t"
    	end

    	# Build address from tags
    	description = ""
    	description += street + " " if street
    	description += housenumber if housenumber
    	description += "<br/>" if description != ""
    	description += postcode + " " if postcode
    	description += city if city
	description = "(Keine Adresse angegeben)" if description == ""
    	if description_extra != ""
	    description += "<br/>" + description_extra
	end
    	file << description + "\t"

    	# put icon information
    	file << icon

	file << "\n"

	count += 1
    end
    file.close()

    return count
end



########################
# tag: club-mate=yes
########################


# download
download($URL_club_mate, $XML_club_mate)

icons = Hash.new()
icons["default"] = "./icon_club-mate-obsolet_37x37_-12x-25.png\t37,37\t-12,-25"

# Add Note about obsolete tag
description_extra = "<br/>HINWEIS:<br/>"
description_extra += "Der Tag club-mate=yes ist obsolet. Bitte benutze statt dessen drink:club-mate=*."

$count_club_mate += parse($XML_club_mate, $TXT_club_mate, "club-mate", description_extra, icons)



###########################
# tag: drink:club-mate=*
###########################

# download
download($URL_drink_club_mate, $XML_drink_club_mate)

icons = Hash.new()
icons["retail"] = "./icon_club-mate-retail_30x40_-12x-28.png\t30,40\t-12,-28"
icons["served"] = "./icon_club-mate-served_32x40_-12x-28.png\t32,40\t-12,-28"
icons["default"] = "./icon_club-mate_24x24_-12x-12.png\t24,24\t-12,-12"
$count_drink_club_mate += parse($XML_drink_club_mate, $TXT_drink_club_mate, "drink:club-mate", "", icons)




###########################
# tag: drink:afri-cola=*
###########################

# Download data
download($URL_drink_afri_cola, $XML_drink_afri_cola)

icons = Hash.new()
icons["retail"] = "./icon_afri-cola-retail_30x40_-12x-28.png\t30,40\t-12,-28"
icons["served"] = "./icon_afri-cola-served_32x40_-12x-28.png\t32,40\t-12,-28"
icons["default"] = "./icon_afri-cola_24x24_-12x-12.png\t24,24\t-12,-12"
$count_drink_afri_cola += parse($XML_drink_afri_cola, $TXT_drink_afri_cola, "drink:afri-cola", "", icons)


###########################
# Statistics (hacky)
###########################

# TODO: find more elegant solution

outfile = File.new("matecount.html", File::WRONLY|File::CREAT|File::TRUNC)

outfile << "<p>"
outfile << "Derzeit sind #{$count_drink_club_mate+$count_club_mate} Mate-Zugangspunkte "
outfile << "und #{$count_drink_afri_cola} Afri Cola-Zugangspunkte eingetragen. "
outfile << "Stand: " + Time.now.asctime()
outfile << "</p>"

outfile.close()
