# Clock fictício de 100 MHz (10 ns de período)
create_clock -period 10.000 -name clk -waveform {0 5} [get_ports dummy_clk]
