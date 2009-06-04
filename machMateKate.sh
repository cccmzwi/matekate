matefile="matekate.txt"
nodeURL="http://www.informationfreeway.org/api/0.6/node[club-mate=yes]"
wayURL="http://www.informationfreeway.org/api/0.6/way[club-mate=yes]"


rm -f "$matefile"

# get data from server
while (! wget "$nodeURL" -O matenodes.osm)
do
    echo "getting data from server failed (nodes)."
done

while (! wget "$wayURL" -O mateways.osm)
do
    echo "getting data from server failed (ways)."
done

xsltproc osm2text.xsl matenodes.osm | sed 's/^\s\s//g' > matekate.txt
xsltproc osm2text.xsl mateways.osm | sed 's/^\s\s//g' | sed '/^lat\t/ d' >> matekate.txt

# calculate number of shown Mate POIs
matecount=`cat matekate.txt | egrep '^[[:digit:]]' | wc -l`

echo "<p>Derzeit sind $matecount Mate-Zugangspunkte eingetragen.</p>" > matecount.html
