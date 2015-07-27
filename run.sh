#!/bin/bash

MAX_PACKS=1000000
repetitions=20
num_port=1820
total_ports_list="1 2 4 8 16 24 32"
total_clients=4
client_port_target=13131


for total_ports in $total_ports_list
do
	ports="1820"
	for ((k=1 ; $k<$total_ports ; k++))
	{
		ports="$ports,$(($num_port+$k))"
	}

	# Instalar modulo para esta prueba
	sudo insmod ../UDPRedistributeModule/UDPRedistributeModule.ko verbose=0 _target_hook_port_=13131 _redirect_ports_=$ports

	# Archivo para guardar datos
	salida="times_$total_ports""_sockets.csv"
	for ((i=1 ; $i<=$repetitions ; i++))
	{

		# Lanzar $total_ports instancias de ServerTesis corriendo en puertos distintos partiendo de $num_port
		for ((k=0 ; $k<$total_ports ; k++))
		{
			./serverTesis --packets $(($MAX_PACKS/$total_ports)) --threads 1 --port $(($num_port+$k)) >> aux &
		}

		sleep 1

		for ((j=1 ; $j<=$total_clients ; j++))
		{
			for ((k=0 ; $k<$total_ports ; k++))
			{
				#./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $(($num_port+$k)) > /dev/null &
				./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $client_port_target > /dev/null &
			}
		}

        wait $(pgrep 'serverTesis')
        kill $(pgrep 'clientTesis')
        cat aux >> $salida
        rm aux
        echo "" >> $salida
		echo ""

	}

	sudo rmmod UDPRedistributeModule

done