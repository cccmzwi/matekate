matefile="matekate.txt"
#nodeURL="http://www.informationfreeway.org/api/0.6/node[club-mate=yes]"
nodeURL="http://xapi.openstreetmap.org/api/0.5/node[club-mate=yes]"
#wayURL="http://www.informationfreeway.org/api/0.6/way[club-mate=yes]"
wayURL="http://xapi.openstreetmap.org/api/0.5/way[club-mate=yes]"


# get nodes
if (! wget "$nodeURL" -t 3 -O matenodes.osm.part)
then
    echo "getting data from server failed (nodes)."
    rm -f matenodes.osm.part
    exit 1
else
    mv matenodes.osm.part matenodes.osm
fi
xsltproc osm2text.xsl matenodes.osm | sed 's/^\s\s//g' > "$matefile.part"

# get ways
if (! wget "$wayURL" -t 3 -O mateways.osm.part)
then
    echo "getting data from server failed (ways)."
    rm -f mateways.osm.part
    exit 1
else
    mv mateways.osm.part mateways.osm
fi
xsltproc osm2text.xsl mateways.osm | sed 's/^\s\s//g' | sed '/^lat\t/ d' >> "$matefile.part"

# prepare matefile
rm -f "$matefile"
mv "$matefile.part" "$matefile"


# prepare file with metainfos
matecount=`cat matekate.txt | egrep '^[[:digit:]]' | wc -l`

echo "<p>" > matecount.html
echo "Derzeit sind $matecount Mate-Zugangspunkte eingetragen." >> matecount.html
echo "Stand: `date '+%d.%m.%Y, %H:%M'`" >> matecount.html
echo "</p>" >> matecount.html
