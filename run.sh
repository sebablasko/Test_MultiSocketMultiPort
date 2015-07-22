#!/bin/bash

MAX_PACKS=1000000
repetitions=5
num_port=1820
total_ports_list="5"
total_clients=4
client_port_target=13131

for total_ports in $total_ports_list
do

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
				#./clientTesis --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $(($num_port+$k)) > /dev/null &
				./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $client_port_target > /dev/null &
			}
		}

        wait $(pgrep 'serverTesis')
        kill $(pgrep 'clientTesis')

		echo ""

	}
done