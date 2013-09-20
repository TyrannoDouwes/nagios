#!/bin/bash
#
# Framework voor een rrd script.
# Vervangen:
#
# <TEKST> = tekst die refereert naar de test
# <TEST> = naam van de test zoals die in de RRD file voorkomt.
# <DS-NAME> = data source naam zoals die in de RRD file staat.
# <LABEL> = label in de grafiek
# <LABEL-TEKST> = label tekst in de grafiek

begintijd=($begindag $beginweek $beginmaand)

titel=( "Verbruikte tijd de afgelopen dag" \
	"Verbruikte tijd de afgelopen week" \
	"Verbruikte tijd de afgelopen maand")

cd $rrddir
for rrdfile in *-time.rrd; do

	# bepaal hostname uit filename
	result="$(host ${rrdfile%%_*.rrd})"
	[ $? -eq 0 ] && hostname=$(awk '{print $5}' <<<$result) || hostname="unknown"
	hostname=${hostname%%.*}
	[ "$hostname" = "localhost" ] && hostname="houston"
	DomU=${rrdfile%%_time.rrd}
	DomU=${DomU##*_}

	filenaam=("${pngdir}/${hostname}-${DomU}-time-dag.png"	\
		"${pngdir}/${hostname}-${DomU}-time-week.png"	\
		"${pngdir}/${hostname}-${DomU}-time-maand.png")

	echo "$DomU verbruikte tijd" > ${pngdir}/${hostname}-${DomU}-time.header

	for i in 0 1 2; do
		rrdtool graph ${filenaam[$i]}                   \
		--start ${begintijd[$i]} --end $eindtijd        \
		--vertical-label "Verbruikte tijd"              \
		--title "${titel[$i]}"                          \
		--height 200					\
		DEF:tijd=${rrdfile}:time:MAX                    \
		LINE2:tijd#000000:"Verbruikte tijd"             > /dev/null 2>&1
	done
done

