#!/bin/bash

begintijd=($begindag $beginweek $beginmaand)

# Genereer de grafieken voor de cpu load.
# Zet een bovengrens voor de grafiek anders weet rrdtool niet hoe die de
# Y-as moet schalen. Twee cpu's kan algauw een load van 2 geven, dus 2 is
# een mooie bovengrens. Bij een eventuele overschrijding zal rrdtool de
# schaal automatisch aanpassen.

cd $rrddir
for rrdfile in *_postfix_queued.rrd; do

	# bepaal hostname uit filename
	result="$(host ${rrdfile%%_postfix_queued.rrd})"
	[ $? -eq 0 ] && hostname=$(awk '{print $5}' <<<$result) || hostname="unknown"
	hostname=${hostname%%.*}
	[ "$hostname" = "localhost" ] && hostname="houston"

	titel=( "mail queue de afgelopen dag" \
		"mail queue de afgelopen week" \
		"mail queue de afgelopen maand")

	filenaam=("${pngdir}/${hostname}-postfix-queued-dag.png"	\
		"${pngdir}/${hostname}-postfix-queued-week.png"	\
		"${pngdir}/${hostname}-postfix-queued-maand.png")

	# Zet de header voor op de HTML pagina
	echo "Postfix queue" > ${pngdir}/${hostname}-postfix-queued.header

	rrdtool graph ${filenaam[0]}                            \
		--start ${begintijd[0]} --end $eindtijd         \
		--vertical-label queued                      \
		--title "${titel[0]}"                           \
		--height $hoogte                                \
		--lower-limit 0                                 \
		DEF:queued=${rrdfile}:queued:MAX              \
		LINE2:queued#000000:"queued email"              > /dev/null 2>&1

	for i in 1 2; do
		rrdtool graph ${filenaam[$i]}                            \
			--start ${begintijd[$i]} --end $eindtijd         \
			--vertical-label queued                      \
			--title "${titel[$i]}"                           \
			--height $hoogte                                \
			--lower-limit 0                                 \
			DEF:queued=${rrdfile}:queued:AVERAGE              \
			LINE2:queued#000000:"queued email"              > /dev/null 2>&1
	done
done

