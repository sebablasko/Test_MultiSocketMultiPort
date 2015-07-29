#!/bin/bash

MAX_PACKS=1000000
repetitions=20
num_port=1820
total_ports_list="1 2 4 8 16 24 36"
total_clients=4
client_port_target=13131

#MODULO
for total_ports in $total_ports_list
do
	echo "Evaluando $total_ports Usando modulo..."

	# Instalar modulo para esta prueba
	sudo insmod ../UDPRedistributeModule/UDPRedistributeModule.ko verbose=0 hook_port=$client_port_target start_redirect_port=$num_port number_redirect_ports=$total_ports

	# Archivo para guardar datos
	if (($total_ports >= 0 & $total_ports < 10)); then salida="modulo_Times_00$total_ports""_sockets.csv"; fi
	if (($total_ports >= 10 & $total_ports < 100)); then salida="modulo_Times_0$total_ports""_sockets.csv"; fi
	if (($total_ports >= 100)); then salida="modulo_Times_$total_ports""_sockets.csv"; fi

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		echo "Repeticion $i"

		# Lanzar $total_ports instancias de ServerTesis corriendo en puertos distintos partiendo de $num_port
		for ((k=0 ; $k<$total_ports ; k++))
		{
			./serverTesis --packets $(($MAX_PACKS/$total_ports)) --threads 1 --port $(($num_port+$k)) >> aux &
		}

		sleep 1

		for ((j=1 ; $j<=$total_clients ; j++))
		{
			#for ((k=0 ; $k<$total_ports ; k++))
			##{
				#./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $(($num_port+$k)) > /dev/null &
				./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $client_port_target > /dev/null &
			#}
		}

        wait $(pgrep 'serverTesis')
        kill $(pgrep 'clientTesis')
        cat aux >> $salida
        rm aux
        echo "" >> $salida
	}

	sudo rmmod UDPRedistributeModule

done

echo "Compilando resultados"

cat modulo_Times_* > results_modulo.csv
sed 's/;//g' results_modulo.csv | sed 's/,//g' | sed 's/\./,/g' > results_modulo_FIX.csv
echo "done"


#REUSEPORT
for total_ports in $total_ports_list
do
	echo "Evaluando $total_ports Usando ReusePORT..."

	# Archivo para guardar datos
	if (($total_ports >= 0 & $total_ports < 10)); then salida="reuseport_Times_00$total_ports""_sockets.csv"; fi
	if (($total_ports >= 10 & $total_ports < 100)); then salida="reuseport_Times_0$total_ports""_sockets.csv"; fi
	if (($total_ports >= 100)); then salida="reuseport_Times_$total_ports""_sockets.csv"; fi

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		echo "Repeticion $i"

		# Lanzar $total_ports instancias de ServerTesis corriendo en puertos distintos partiendo de $num_port
		for ((k=0 ; $k<$total_ports ; k++))
		{
			./serverTesis --packets $(($MAX_PACKS/$total_ports)) --threads 1 --port $num_port --reuseport >> aux &
		}

		sleep 1

		for ((j=1 ; $j<=$total_clients ; j++))
		{
			#for ((k=0 ; $k<$total_ports ; k++))
			##{
				./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
			#}
		}

        wait $(pgrep 'serverTesis')
        kill $(pgrep 'clientTesis')
        cat aux >> $salida
        rm aux
        echo "" >> $salida
	}

done

echo "Compilando resultados"

cat reuseport_Times_* > results_reuseport.csv
sed 's/;//g' results_reuseport.csv | sed 's/,//g' | sed 's/\./,/g' > results_reuseport_FIX.csv

echo "done"
