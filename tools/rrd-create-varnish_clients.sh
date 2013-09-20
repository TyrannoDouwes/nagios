#!/bin/bash

begintijd=($begindag $beginweek $beginmaand)

# Genereer de grafieken voor de cpu load.
# Zet een bovengrens voor de grafiek anders weet rrdtool niet hoe die de
# Y-as moet schalen. Twee cpu's kan algauw een load van 2 geven, dus 2 is
# een mooie bovengrens. Bij een eventuele overschrijding zal rrdtool de
# schaal automatisch aanpassen.

titel=( "Varnish client connecties de afgelopen dag" \
	"Varnish client connecties de afgelopen week" \
	"Varnish client connecties de afgelopen maand")

cd $rrddir
for rrdfile in *-varnish_clients.rrd; do

	# bepaal hostname uit filename
	result="$(host ${rrdfile%%-varnish_clients.rrd})"
	[ $? -eq 0 ] && hostname=$(awk '{print $5}' <<<$result) || hostname="unknown"
	hostname=${hostname%%.*}
	[ "$hostname" = "localhost" ] && hostname="houston"

	filenaam=("${pngdir}/${hostname}-varnish_clients-dag.png"	\
		"${pngdir}/${hostname}-varnish_clients-week.png"	\
		"${pngdir}/${hostname}-varnish_clients-maand.png")

	echo "Varnish client connections" > ${pngdir}/${hostname}-varnish_clients.header

	for i in 0 1 2; do
		rrdtool graph ${filenaam[$i]}                           \
		--start ${begintijd[$i]} --end $eindtijd        \
		--vertical-label "average client conns per sec"                       \
		--title "${titel[$i]}"                          \
		--height $hoogte                                \
		--upper-limit 1                                 \
		DEF:conn=${rrdfile}:client_conn:MAX                   \
		DEF:drop=${rrdfile}:client_drop:MAX                   \
		DEF:req=${rrdfile}:client_req:MAX                   \
		LINE2:conn#FF0000:"connections"                       \
		LINE2:drop#00FF00:"droppped"                       \
		LINE2:req#0000FF:"requests"                       > /dev/null 2>&1
	done
done

