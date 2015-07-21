#!/bin/bash

MAX_PACKS=1250000
repetitions=3
num_port=1820
total_ports=1
total_clients=4

for ((i=1 ; $i<=$repetitions ; i++))
{
	# Lanzar $total_ports instancias de ServerTesis corriendo en puertos distintos
	for ((k=0 ; $k<$total_ports ; k++))
	{
		./serverTesis --packets $(($MAX_PACKS/$total_ports)) --threads 1 --port $(($num_port+$k)) &
	}

	sleep 1

	for ((j=1 ; $j<=$total_clients ; j++))
	{
		for ((k=0 ; $k<$total_ports ; k++))
		{
			./clientTesis --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $(($num_port+$k)) > /dev/null &
		}
	}

	wait $(pgrep 'serverTesis')

	echo ""

}