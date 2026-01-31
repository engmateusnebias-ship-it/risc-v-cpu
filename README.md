\# RISC-V CPU Core (RV32I)

\# Developed by engineer Mateus Telles Nébias



This project implements a minimalist RISC-V RV32I CPU core from scratch using synthesizable VHDL. It is designed for educational purposes and as a demonstration of digital design and computer architecture skills. The processor is capable of executing a subset of the RISC-V instruction set and can be synthesized on an FPGA.



\##  Features



\- \*\*Instruction Set\*\*: RV32I base integer instruction set

\- \*\*Pipeline\*\*: Single-cycle architecture (1-stage pipeline)

\- \*\*Register File\*\*: 32 general-purpose 32-bit registers

\- \*\*Memory\*\*: Separate instruction and data memory (BRAM)

\- \*\*Peripherals\*\*:

  - UART (TX/RX)

  - GPIO (LEDs, buttons)

  - Timer (optional)

\- \*\*Memory-Mapped I/O\*\* for peripheral access

\- \*\*Firmware\*\*: Written in C using the RISC-V GCC toolchain



\##  Project Structure

risc-v-cpu/

├── rtl/           # VHDL source files

├── tb/            # Testbenches in VHDL

├── firmware/      # RISC-V C firmware

├── docs/          # Documentation (block diagrams, memory map, etc.)

├── scripts/       # Build and simulation scripts

├── constraints/   # FPGA constraint files (e.g., XDC)

├── README.md

└── .gitignore





\##  Verification



\- Unit tests for ALU, register file, and control logic

\- Integration testbench for full CPU execution

\- UART loopback test

\- VCD waveform generation for debugging



\##  Tools Used



\- VHDL

\- \*\*GHDL / ModelSim\*\* for simulation

\- Vivado for synthesis and FPGA implementation

\- \*\*RISC-V GCC Toolchain\*\* for firmware compilation

\- \*\*GTKWave\*\* for waveform analysis



\## 🖥️ FPGA Target



\- Designed for \[Your FPGA Board Name Here]  

&nbsp; (e.g., Digilent Basys 3, DE10-Lite, etc.)



\## 📷 Demo



> \_Coming soon: video demo of the CPU running firmware and communicating via UART.\_



\## 📚 Documentation



\- Block diagram of CPU architecture

\- Instruction decoding table

\- Memory map and peripheral register layout

\- Timing diagrams for UART and memory access



\## 🧠 Motivation



This project was developed as a personal initiative to deepen my understanding of computer architecture, digital design, and hardware-software co-design. It serves as a portfolio piece to demonstrate my ability to design, verify, and implement a working CPU core on FPGA using VHDL.



\## 📌 Roadmap



\- \[x] ALU and Register File (VHDL)

\- \[x] Instruction Decoder and Control Unit

\- \[x] Memory Integration

\- \[x] UART Peripheral

\- \[x] Firmware Toolchain Setup

\- \[ ] Timer Peripheral

\- \[ ] Pipeline Optimization (2-stage or 3-stage)

\- \[ ] AXI-lite Bus Integration

\- \[ ] Cache (optional)



\## 📜 License



This project is released under the MIT License.



