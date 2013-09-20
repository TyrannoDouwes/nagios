#!/bin/bash

begintijd=($begindag $beginweek $beginmaand)

# Genereer de grafieken voor de cpu load.
# Zet een bovengrens voor de grafiek anders weet rrdtool niet hoe die de
# Y-as moet schalen. Twee cpu's kan algauw een load van 2 geven, dus 2 is
# een mooie bovengrens. Bij een eventuele overschrijding zal rrdtool de
# schaal automatisch aanpassen.

titel=( "Varnish cache statistieken de afgelopen dag" \
	"Varnish cache statistieken de afgelopen week" \
	"Varnish cache statistieken de afgelopen maand")

cd $rrddir
for rrdfile in *-varnish_cache.rrd; do

	# bepaal hostname uit filename
	result="$(host ${rrdfile%%-varnish_cache.rrd})"
	[ $? -eq 0 ] && hostname=$(awk '{print $5}' <<<$result) || hostname="unknown"
	hostname=${hostname%%.*}
	[ "$hostname" = "localhost" ] && hostname="houston"

	filenaam=("${pngdir}/${hostname}-varnish_cache-dag.png"	\
		"${pngdir}/${hostname}-varnish_cache-week.png"	\
		"${pngdir}/${hostname}-varnish_cache-maand.png")

	echo "Varnish cache" > ${pngdir}/${hostname}-varnish_cache.header

	for i in 0 1 2; do
		rrdtool graph ${filenaam[$i]}                           \
		--start ${begintijd[$i]} --end $eindtijd        \
		--vertical-label "average cache hits per sec"          \
		--title "${titel[$i]}"                          \
		--height $hoogte                                \
		--upper-limit 1                                 \
		DEF:hit=${rrdfile}:cache_hit:MAX                   \
		DEF:hitpass=${rrdfile}:cache_hitpass:MAX                   \
		DEF:miss=${rrdfile}:cache_miss:MAX                   \
		LINE2:hit#FF0000:"hit"                       \
		LINE2:hitpass#00FF00:"hitpass"                       \
		LINE2:miss#0000FF:"miss"                       > /dev/null 2>&1
	done
done

