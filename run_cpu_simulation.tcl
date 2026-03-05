# Add top-level testbench signals to the waveform
add_wave sim:/tb_cpu/clk
add_wave sim:/tb_cpu/rst
add_wave sim:/tb_cpu/gpio_toggle
add_wave sim:/tb_cpu/gpio_out

# Add internal CPU signals (uut instance) to the waveform
add_wave sim:/tb_cpu/uut/pc
add_wave sim:/tb_cpu/uut/next_pc
add_wave sim:/tb_cpu/uut/instruction
add_wave sim:/tb_cpu/uut/rs1_data
add_wave sim:/tb_cpu/uut/rs2_data
add_wave sim:/tb_cpu/uut/write_back_data
add_wave sim:/tb_cpu/uut/imm
add_wave sim:/tb_cpu/uut/alu_input_b
add_wave sim:/tb_cpu/uut/alu_result
add_wave sim:/tb_cpu/uut/alu_zero
add_wave sim:/tb_cpu/uut/alu_control_signal
add_wave sim:/tb_cpu/uut/mem_read_data
add_wave sim:/tb_cpu/uut/gpio_read_data
add_wave sim:/tb_cpu/uut/gpio_out_en
add_wave sim:/tb_cpu/uut/gpio_in_en
add_wave sim:/tb_cpu/uut/gpio_addr
add_wave sim:/tb_cpu/uut/gpio_write_data
add_wave sim:/tb_cpu/uut/reg_write
add_wave sim:/tb_cpu/uut/alu_src
add_wave sim:/tb_cpu/uut/mem_read
add_wave sim:/tb_cpu/uut/mem_write
add_wave sim:/tb_cpu/uut/mem_to_reg
add_wave sim:/tb_cpu/uut/branch
add_wave sim:/tb_cpu/uut/jump

# Run the simulation for 12 seconds
run 12s

# Save the waveform to a VCD file
write_vcd tb_cpu_simulation.vcd

# Print completion message
puts "Simulation performed and waveform saved as tb_cpu_simulation.vcd"
