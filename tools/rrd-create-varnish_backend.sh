#!/bin/bash

begintijd=($begindag $beginweek $beginmaand)

# Genereer de grafieken voor de cpu load.
# Zet een bovengrens voor de grafiek anders weet rrdtool niet hoe die de
# Y-as moet schalen. Twee cpu's kan algauw een load van 2 geven, dus 2 is
# een mooie bovengrens. Bij een eventuele overschrijding zal rrdtool de
# schaal automatisch aanpassen.

titel=( "Varnish backend connecties de afgelopen dag" \
	"Varnish backend connecties de afgelopen week" \
	"Varnish backend connecties de afgelopen maand")

cd $rrddir
for rrdfile in *-varnish_backend.rrd; do

	# bepaal hostname uit filename
	result="$(host ${rrdfile%%-varnish_backend.rrd})"
	[ $? -eq 0 ] && hostname=$(awk '{print $5}' <<<$result) || hostname="unknown"
	hostname=${hostname%%.*}
	[ "$hostname" = "localhost" ] && hostname="houston"

	filenaam=("${pngdir}/${hostname}-varnish_backend-dag.png"	\
		"${pngdir}/${hostname}-varnish_backend-week.png"	\
		"${pngdir}/${hostname}-varnish_backend-maand.png")

	echo "Varnish backend connections" > ${pngdir}/${hostname}-varnish_backend.header

	for i in 0 1 2; do
		rrdtool graph ${filenaam[$i]}                           \
		--start ${begintijd[$i]} --end $eindtijd        \
		--vertical-label "average backend conns per sec" \
		--title "${titel[$i]}"                          \
		--height $hoogte                                \
		--upper-limit 1                                 \
		DEF:conn=${rrdfile}:backend_conn:MAX                   \
		DEF:busy=${rrdfile}:backend_busy:MAX                   \
		DEF:retry=${rrdfile}:backend_retry:MAX                   \
		LINE2:conn#FF0000:"connections"                       \
		LINE2:busy#00FF00:"busy"                       \
		LINE2:retry#0000FF:"retry"                       > /dev/null 2>&1
	done
done

