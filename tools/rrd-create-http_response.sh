#!/bin/bash

begintijd=($begindag $beginweek $beginmaand)

# Genereer de grafieken voor de cpu load.
# Zet een bovengrens voor de grafiek anders weet rrdtool niet hoe die de
# Y-as moet schalen. Twee cpu's kan algauw een load van 2 geven, dus 2 is
# een mooie bovengrens. Bij een eventuele overschrijding zal rrdtool de
# schaal automatisch aanpassen.

titel=( "HTTP response tijd de afgelopen dag" \
	"HTTP response tijd de afgelopen week" \
	"HTTP response tijd de afgelopen maand")

cd $rrddir
for rrdfile in *-http_response-*.rrd; do

	# bepaal hostname uit filename
	website="${rrdfile%%-http_response-*.rrd}"
	url=$(basename ${rrdfile##*-http_response-} .rrd)
	realurl=$(sed -e 's/___/\//g' -e 's/_PARS_/\?/g' -e 's/_EMP_/\&/g' -e 's/_DOLLAR_/\$/g' <<<$url)

	[ "$1" = "-v" ] && echo "rrdfile=$rrdfile, website=$website, url=$url, realurl=$realurl"

	filenaam=("${pngdir}/websites-${website}-${url}-dag.png"	\
		"${pngdir}/websites-${website}-${url}-week.png"	\
		"${pngdir}/websites-${website}-${url}-maand.png")

	webserver=${website%%_*}
	[ "$webserver" != "$website" ] && realurl="$realurl via ${website##*_}"

	echo "http://${webserver}$realurl" > ${pngdir}/websites-${website}-${url}.header

	for i in 0 1 2; do
		[ "$1" = "-v" ] && echo "creating ${filenaam[$i]} out of $rrdfile"
		rrdtool graph ${filenaam[$i]}                   \
		--start ${begintijd[$i]} --end $eindtijd        \
		--vertical-label "HTTP response in sec"         \
		--title "${titel[$i]}"                          \
		--height $hoogte                                \
		DEF:time=${rrdfile}:time:MAX                   \
		LINE2:time#0000FF:"response"                       >/dev/null 2>&1
	done
done

