library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top-level single-cycle RV32I CPU + simple SoC peripherals (GPIO + TIMER + RAM).
-- This module instantiates the core datapath blocks and the memory-mapped interconnect.
entity cpu is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        -- External GPIO input (button)
        gpio_toggle : in  std_logic;
        -- External GPIO output (LEDs)
        gpio_out    : out std_logic_vector(31 downto 0)
    );
end cpu;

architecture rtl of cpu is

    -- JALR requires clearing bit 0 of the computed target address.
    -- Use a numeric_std constant to avoid ambiguous type conversions in VHDL-93/2002.
    constant JALR_ALIGN_MASK : unsigned(31 downto 0) := unsigned'(x"FFFFFFFE");
-- PC / Instruction
    signal pc, next_pc, pc_plus4 : std_logic_vector(31 downto 0);
    signal instruction           : std_logic_vector(31 downto 0);

    -- Decode fields
    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal rs1_addr, rs2_addr, rd_addr : std_logic_vector(4 downto 0);

    -- Control
    signal reg_write      : std_logic;
    signal alu_src_a_pc   : std_logic;
    signal alu_src_b_imm  : std_logic;
    signal alu_op_ctrl    : std_logic_vector(1 downto 0);
    signal is_branch      : std_logic;
    signal is_jal         : std_logic;
    signal is_jalr        : std_logic;
    signal wb_sel         : std_logic_vector(1 downto 0);
    signal mem_re, mem_we : std_logic;
    signal mem_size       : std_logic_vector(1 downto 0);
    signal mem_unsigned   : std_logic;
    signal fence_nop      : std_logic;
    signal ecall, ebreak  : std_logic;
    signal illegal_insn   : std_logic;

    -- Register file
    signal rs1_data, rs2_data : std_logic_vector(31 downto 0);
    signal wb_data            : std_logic_vector(31 downto 0);

    -- Immediate
    signal imm : std_logic_vector(31 downto 0);

    -- ALU
    signal alu_a, alu_b     : std_logic_vector(31 downto 0);
    signal alu_result       : std_logic_vector(31 downto 0);
    signal alu_zero         : std_logic;
    signal alu_ctrl_sig     : std_logic_vector(3 downto 0);

    -- Branch compare
    signal branch_taken : std_logic;

    -- LSU
    signal lsu_wdata   : std_logic_vector(31 downto 0);
    signal lsu_wstrb   : std_logic_vector(3 downto 0);
    signal load_result : std_logic_vector(31 downto 0);
    signal ls_misaligned : std_logic;

    -- Bus (CPU side)
    signal bus_addr  : std_logic_vector(31 downto 0);
    signal bus_we, bus_re : std_logic;
    signal bus_wdata : std_logic_vector(31 downto 0);
    signal bus_wstrb : std_logic_vector(3 downto 0);
    signal bus_rdata : std_logic_vector(31 downto 0);

    -- RAM side
    signal ram_we, ram_re : std_logic;
    signal ram_addr : std_logic_vector(31 downto 0);
    signal ram_wdata : std_logic_vector(31 downto 0);
    signal ram_wstrb : std_logic_vector(3 downto 0);
    signal ram_rdata : std_logic_vector(31 downto 0);

    -- GPIO side
    signal gpio_we, gpio_re : std_logic;
    signal gpio_addr : std_logic_vector(31 downto 0);
    signal gpio_wdata : std_logic_vector(31 downto 0);
    signal gpio_wstrb : std_logic_vector(3 downto 0);
    signal gpio_rdata : std_logic_vector(31 downto 0);

    -- TIMER side
    signal timer_we, timer_re : std_logic;
    signal timer_addr : std_logic_vector(31 downto 0);
    signal timer_wdata : std_logic_vector(31 downto 0);
    signal timer_wstrb : std_logic_vector(3 downto 0);
    signal timer_rdata : std_logic_vector(31 downto 0);
    signal timer_irq   : std_logic;

    -- External GPIO outputs are 4-bit at the peripheral; expose as 32-bit at CPU top level.
    signal gpio_out4 : std_logic_vector(3 downto 0);

    -- Trap
    signal misaligned_fetch : std_logic;
    signal trap_taken : std_logic;
    signal trap_target : std_logic_vector(31 downto 0);
    signal trap_cause  : std_logic_vector(3 downto 0);

    -- Next PC candidates
    signal pc_branch_target : std_logic_vector(31 downto 0);
    signal pc_jal_target    : std_logic_vector(31 downto 0);
    signal pc_jalr_target   : std_logic_vector(31 downto 0);

    -- Gated side effects
    signal reg_write_g : std_logic;
    signal mem_re_g, mem_we_g : std_logic;

begin
    -- Decode fields
    opcode   <= instruction(6 downto 0);
    funct3   <= instruction(14 downto 12);
    funct7   <= instruction(31 downto 25);
    rs1_addr <= instruction(19 downto 15);
    rs2_addr <= instruction(24 downto 20);
    rd_addr  <= instruction(11 downto 7);

    -- PC register
    pc_reg: entity work.program_counter
        port map (
            clk     => clk,
            rst     => rst,
            enable  => '1',
            next_pc => next_pc,
            pc      => pc
        );

    pc_plus4 <= std_logic_vector(unsigned(pc) + 4);

    -- Instruction memory
    instr_mem: entity work.instruction_memory
        port map (
            addr        => pc,
            instruction => instruction
        );

    -- Control unit
    ctrl: entity work.control_unit
        port map (
            instr         => instruction,
            reg_write     => reg_write,
            alu_src_a_pc  => alu_src_a_pc,
            alu_src_b_imm => alu_src_b_imm,
            alu_op_ctrl   => alu_op_ctrl,
            is_branch     => is_branch,
            is_jal        => is_jal,
            is_jalr       => is_jalr,
            wb_sel        => wb_sel,
            mem_re        => mem_re,
            mem_we        => mem_we,
            mem_size      => mem_size,
            mem_unsigned  => mem_unsigned,
            fence_nop     => fence_nop,
            ecall         => ecall,
            ebreak        => ebreak,
            illegal_insn  => illegal_insn
        );

    -- Register file
    reg_file: entity work.register_file
        port map (
            clk          => clk,
            we           => reg_write_g,
            rs1_addr     => rs1_addr,
            rs2_addr     => rs2_addr,
            rd_addr      => rd_addr,
            rd_data_in   => wb_data,
            rs1_data_out => rs1_data,
            rs2_data_out => rs2_data
        );

    -- Immediate generator
    imm_gen: entity work.immediate_generator
        port map (
            instr   => instruction,
            imm_out => imm
        );

    -- ALU control
    alu_ctrl: entity work.alu_control
        port map (
            opcode             => opcode,
            alu_op_ctrl        => alu_op_ctrl,
            funct3             => funct3,
            funct7             => funct7,
            alu_control_signal => alu_ctrl_sig
        );

    -- ALU operand muxes
    alu_a <= pc when alu_src_a_pc = '1' else rs1_data;
    alu_b <= imm when alu_src_b_imm = '1' else rs2_data;

    -- ALU
    alu_inst: entity work.alu
        port map (
            A      => alu_a,
            B      => alu_b,
            alu_op => alu_ctrl_sig,
            result => alu_result,
            zero   => alu_zero
        );

    -- Branch comparator
    brcmp: entity work.branch_compare
        port map (
            funct3       => funct3,
            rs1          => rs1_data,
            rs2          => rs2_data,
            branch_taken => branch_taken
        );

    -- LSU
    lsu: entity work.load_store_unit
        port map (
            addr           => alu_result,
            funct3         => funct3,
            is_load        => mem_re,
            is_store       => mem_we,
            rs2_store_data => rs2_data,
            mem_rdata_raw  => bus_rdata,
            mem_wdata      => lsu_wdata,
            mem_wstrb      => lsu_wstrb,
            load_result    => load_result,
            misaligned     => ls_misaligned
        );

    -- Trap detection
    misaligned_fetch <= '1' when pc(1 downto 0) /= "00" else '0';

    traps: entity work.trap_unit
        port map (
            pc               => pc,
            illegal_insn     => illegal_insn,
            ecall            => ecall,
            ebreak           => ebreak,
            misaligned_ls    => ls_misaligned,
            misaligned_fetch => misaligned_fetch,
            trap_taken       => trap_taken,
            trap_target      => trap_target,
            trap_cause       => trap_cause
        );

    -- Gate side effects on traps
    reg_write_g <= reg_write and (not trap_taken);
    mem_re_g    <= mem_re and (not trap_taken) and (not ls_misaligned);
    mem_we_g    <= mem_we and (not trap_taken) and (not ls_misaligned);

    -- Bus signals from CPU
    bus_addr  <= alu_result;
    bus_re    <= mem_re_g;
    bus_we    <= mem_we_g;
    bus_wdata <= lsu_wdata;
    bus_wstrb <= lsu_wstrb when mem_we_g = '1' else "0000";

    -- Interconnect
    intercon: entity work.bus_interconnect
        port map (
            addr        => bus_addr,
            we          => bus_we,
            re          => bus_re,
            wdata       => bus_wdata,
            wstrb       => bus_wstrb,
            rdata       => bus_rdata,

            ram_we      => ram_we,
            ram_re      => ram_re,
            ram_addr    => ram_addr,
            ram_wdata   => ram_wdata,
            ram_wstrb   => ram_wstrb,
            ram_rdata   => ram_rdata,

            gpio_we     => gpio_we,
            gpio_re     => gpio_re,
            gpio_addr   => gpio_addr,
            gpio_wdata  => gpio_wdata,
            gpio_wstrb  => gpio_wstrb,
            gpio_rdata  => gpio_rdata,

            timer_we    => timer_we,
            timer_re    => timer_re,
            timer_addr  => timer_addr,
            timer_wdata => timer_wdata,
            timer_wstrb => timer_wstrb,
            timer_rdata => timer_rdata
        );

    -- Data RAM
    ram: entity work.data_memory
        port map (
            clk   => clk,
            we    => ram_we,
            re    => ram_re,
            addr  => ram_addr,
            wdata => ram_wdata,
            wstrb => ram_wstrb,
            rdata => ram_rdata
        );

    -- GPIO peripheral
    gpio0: entity work.gpio
        port map (
            clk         => clk,
            rst         => rst,
            we          => gpio_we,
            re          => gpio_re,
            addr        => gpio_addr,
            wdata       => gpio_wdata,
            wstrb       => gpio_wstrb,
            rdata       => gpio_rdata,
            gpio_out    => gpio_out4,
            gpio_toggle => gpio_toggle
        );

    -- Drive 32-bit external GPIO output (LEDs) from the 4-bit GPIO peripheral.
    gpio_out <= (31 downto 4 => '0') & gpio_out4;

    -- TIMER peripheral
    tim0: entity work.timer
        port map (
            clk   => clk,
            rst   => rst,
            we    => timer_we,
            re    => timer_re,
            addr  => timer_addr,
            wdata => timer_wdata,
            wstrb => timer_wstrb,
            rdata => timer_rdata,
            irq   => timer_irq
        );

    -- Writeback mux
    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(wb_sel, alu_result, load_result, pc_plus4)
    begin
        case wb_sel is
            when "00" => wb_data <= alu_result;
            when "01" => wb_data <= load_result;
            when "10" => wb_data <= pc_plus4;
            when others => wb_data <= alu_result;
        end case;
    end process;

    -- Next PC targets
    pc_branch_target <= std_logic_vector(unsigned(pc) + unsigned(imm));
    pc_jal_target    <= std_logic_vector(unsigned(pc) + unsigned(imm));

    -- JALR target: (rs1 + imm) & ~1
    pc_jalr_target   <= std_logic_vector((unsigned(rs1_data) + unsigned(imm)) and JALR_ALIGN_MASK);

    -- Next PC selection (priority: trap -> jalr -> jal -> branch -> pc+4)
    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(pc_plus4, trap_taken, trap_target, is_jalr, pc_jalr_target, is_jal, pc_jal_target, is_branch, branch_taken, pc_branch_target)
    begin
        next_pc <= pc_plus4;

        if trap_taken = '1' then
            next_pc <= trap_target;
        elsif is_jalr = '1' then
            next_pc <= pc_jalr_target;
        elsif is_jal = '1' then
            next_pc <= pc_jal_target;
        elsif is_branch = '1' and branch_taken = '1' then
            next_pc <= pc_branch_target;
        else
            next_pc <= pc_plus4;
        end if;
    end process;

end rtl;
