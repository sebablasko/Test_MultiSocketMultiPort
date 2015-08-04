# Test_MultiSocketMultiPort

Prueba para comparar el rendimiento de
- Threads
- ReusePort
- Modulo UDPRedistributeModule
	- Secuential Sched
	- Random Sched

Para ello, evalúa la secuencia de "1 2 4 8 16 24 36 48 64 128" Threads/Sockets consumiendo 1GB de datos en 50 repeticiones.
