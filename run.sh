#!/bin/bash

MAX_PACKS=1000000
repetitions=100
num_port=1820
total_ports_list="1 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 48 64 72 96 128"
total_clients=4
client_port_target=13131

#MODULO USANDO RANDOM
for total_ports in $total_ports_list
do
	echo "Evaluando $total_ports Sockets Usando modulo con Random..."

	# Instalar modulo usando con port_sched=Random
	sudo insmod ../UDPRedistributeModule/UDPRedistributeModule.ko verbose=0 hook_port=$client_port_target start_redirect_port=$num_port number_redirect_ports=$total_ports port_sched=1

	# Archivo para guardar datos
	if (($total_ports >= 0 & $total_ports < 10)); then salida="modulo_randomSched_Times_00$total_ports""_sockets.csv"; fi
	if (($total_ports >= 10 & $total_ports < 100)); then salida="modulo_randomSched_Times_0$total_ports""_sockets.csv"; fi
	if (($total_ports >= 100)); then salida="modulo_randomSched_Times_$total_ports""_sockets.csv"; fi

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
			./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $client_port_target > /dev/null &
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

cat modulo_randomSched_Times_* > results_randomSched_modulo.csv
sed 's/;//g' results_randomSched_modulo.csv | sed 's/,//g' | sed 's/\./,/g' > results_randomSched_modulo_FIX.csv
echo "done"


#MODULO USANDO SEQUENTIAL
for total_ports in $total_ports_list
do
	echo "Evaluando $total_ports Sockets Usando modulo con Sequential..."

	# Instalar modulo usando con port_sched=Sequential
	sudo insmod ../UDPRedistributeModule/UDPRedistributeModule.ko verbose=0 hook_port=$client_port_target start_redirect_port=$num_port number_redirect_ports=$total_ports port_sched=2

	# Archivo para guardar datos
	if (($total_ports >= 0 & $total_ports < 10)); then salida="modulo_sequentialSched_Times_00$total_ports""_sockets.csv"; fi
	if (($total_ports >= 10 & $total_ports < 100)); then salida="modulo_sequentialSched_Times_0$total_ports""_sockets.csv"; fi
	if (($total_ports >= 100)); then salida="modulo_sequentialSched_Times_$total_ports""_sockets.csv"; fi

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
			./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $client_port_target > /dev/null &
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

cat modulo_sequentialSched_Times_* > results_sequentialSched_modulo.csv
sed 's/;//g' results_sequentialSched_modulo.csv | sed 's/,//g' | sed 's/\./,/g' > results_sequentialSched_modulo_FIX.csv
echo "done"



#REUSEPORT
for total_ports in $total_ports_list
do
	echo "Evaluando $total_ports Sockets Usando ReusePORT..."

	# Archivo para guardar datos
	if (($total_ports >= 0 & $total_ports < 10)); then salida="reuseport_Times_00$total_ports""_sockets.csv"; fi
	if (($total_ports >= 10 & $total_ports < 100)); then salida="reuseport_Times_0$total_ports""_sockets.csv"; fi
	if (($total_ports >= 100)); then salida="reuseport_Times_$total_ports""_sockets.csv"; fi

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		echo "Repeticion $i"

		# Lanzar $total_ports instancias de ServerTesis con REUSEPORT corriendo en el mismo puerto con 1 thread por instancia
		for ((k=0 ; $k<$total_ports ; k++))
		{
			./serverTesis --packets $(($MAX_PACKS/$total_ports)) --threads 1 --port $num_port --reuseport >> aux &
		}

		sleep 1

		for ((j=1 ; $j<=$total_clients ; j++))
		{
			./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
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



#USANDO THREADS
for total_ports in $total_ports_list
do
	echo "Evaluando 1 Socket Usando $total_ports threads..."

	# Archivo para guardar datos
	if (($total_ports >= 0 & $total_ports < 10)); then salida="threads_Times_00$total_ports""_sockets.csv"; fi
	if (($total_ports >= 10 & $total_ports < 100)); then salida="threads_Times_0$total_ports""_sockets.csv"; fi
	if (($total_ports >= 100)); then salida="threads_Times_$total_ports""_sockets.csv"; fi

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		echo "Repeticion $i"

		# Lanzar una instancia de ServerTesis corriendo en un puerto usando $total_ports threads de consumo
		./serverTesis --packets $MAX_PACKS --threads $total_ports --port $num_port --reuseport >> aux &

		sleep 1

		for ((j=1 ; $j<=$total_clients ; j++))
		{
			./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
		}

        wait $(pgrep 'serverTesis')
        kill $(pgrep 'clientTesis')
        cat aux >> $salida
        rm aux
        echo "" >> $salida
	}

done

echo "Compilando resultados"

cat threads_Times_* > results_threads.csv
sed 's/;//g' results_threads.csv | sed 's/,//g' | sed 's/\./,/g' > results_threads_FIX.csv

echo "done"



# #USANDO PYPROXY
# for total_ports in $total_ports_list
# do
# 	echo "Evaluando $total_ports pasando por el proxy en python..."

# 	# Ejecutar UDPRedistributePyProxy para distribuir los paquetes
# 	python ../UDPRedistributePyProxy/UDPRedistributePyProxy.py --hook_port $client_port_target --start_redirect_port $num_port --number_redirect_ports $total_ports &
# 	proxypid=$!

# 	# Archivo para guardar datos
# 	if (($total_ports >= 0 & $total_ports < 10)); then salida="pyProxy_Times_00$total_ports""_sockets.csv"; fi
# 	if (($total_ports >= 10 & $total_ports < 100)); then salida="pyProxy_Times_0$total_ports""_sockets.csv"; fi
# 	if (($total_ports >= 100)); then salida="pyProxy_Times_$total_ports""_sockets.csv"; fi

# 	for ((i=1 ; $i<=$repetitions ; i++))
# 	{
# 		echo "Repeticion $i"

# 		# Lanzar $total_ports instancias de ServerTesis corriendo en puertos distintos partiendo de $num_port
# 		for ((k=0 ; $k<$total_ports ; k++))
# 		{
# 			./serverTesis --packets $(($MAX_PACKS/$total_ports)) --threads 1 --port $(($num_port+$k)) >> aux &
# 		}

# 		sleep 1

# 		for ((j=1 ; $j<=$total_clients ; j++))
# 		{
# 			./clientTesis --intensive --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $client_port_target > /dev/null &
# 		}

#         wait $(pgrep 'serverTesis')
#         kill $(pgrep 'clientTesis')
#         cat aux >> $salida
#         rm aux
#         echo "" >> $salida
# 	}

# 	kill $proxypid

# done

# echo "Compilando resultados"

# cat pyProxy_Times_* > results_pyProxy.csv
# sed 's/;//g' results_pyProxy.csv | sed 's/,//g' | sed 's/\./,/g' > results_pyProxy_FIX.csv

# echo "done"
