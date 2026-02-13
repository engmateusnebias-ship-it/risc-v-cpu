library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        gpio_toggle : in  std_logic;
        gpio_out    : out std_logic_vector(3 downto 0)
    );
end cpu;

architecture rtl of cpu is

    -- Program Counter
    signal pc, next_pc : std_logic_vector(31 downto 0);

    -- Instruction
    signal instruction : std_logic_vector(31 downto 0);

    -- Control signals
    signal reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump : std_logic;
    signal alu_op_ctrl : std_logic_vector(1 downto 0);

    -- Register file
    signal rs1_addr, rs2_addr, rd_addr : std_logic_vector(4 downto 0);
    signal rs1_data, rs2_data, write_back_data : std_logic_vector(31 downto 0);

    -- Immediate
    signal imm : std_logic_vector(31 downto 0);

    -- ALU
    signal alu_input_b, alu_result : std_logic_vector(31 downto 0);
    signal alu_zero : std_logic;
    signal alu_control_signal : std_logic_vector(3 downto 0);

    -- Data memory
    signal mem_read_data : std_logic_vector(31 downto 0);

    -- GPIO interface
    signal gpio_read_data : std_logic_vector(31 downto 0);
    signal gpio_out_en, gpio_in_en : std_logic;
    signal gpio_addr, gpio_write_data : std_logic_vector(31 downto 0);

begin

    -- Program Counter
    pc_reg: entity work.program_counter
        port map (
            clk     => clk,
            rst     => rst,
            enable  => '1',
            next_pc => next_pc,
            pc      => pc
        );

    -- Instruction Memory
    instr_mem: entity work.instruction_memory
        port map (
            addr        => pc,
            instruction => instruction
        );

    -- Control Unit
    ctrl: entity work.control_unit
        port map (
            instr        => instruction,
            reg_write    => reg_write,
            alu_src      => alu_src,
            mem_read     => mem_read,
            mem_write    => mem_write,
            mem_to_reg   => mem_to_reg,
            branch       => branch,
            jump         => jump,
            alu_op_ctrl  => alu_op_ctrl
        );

    -- Register File
    rs1_addr <= instruction(19 downto 15);
    rs2_addr <= instruction(24 downto 20);
    rd_addr  <= instruction(11 downto 7);

    reg_file: entity work.register_file
        port map (
            clk          => clk,
            we           => reg_write,
            rs1_addr     => rs1_addr,
            rs2_addr     => rs2_addr,
            rd_addr      => rd_addr,
            rd_data_in   => write_back_data,
            rs1_data_out => rs1_data,
            rs2_data_out => rs2_data
        );

    -- Immediate Generator
    imm_gen: entity work.immediate_generator
        port map (
            instr   => instruction,
            imm_out => imm
        );

    -- ALU Control
    alu_ctrl: entity work.alu_control
        port map (
            alu_op_ctrl        => alu_op_ctrl,
            funct3             => instruction(14 downto 12),
            funct7             => instruction(31 downto 25),
            alu_control_signal => alu_control_signal
        );

    -- ALU input selection
    alu_input_b <= imm when alu_src = '1' else rs2_data;

    -- ALU
    alu_inst: entity work.alu
        port map (
            A       => rs1_data,
            B       => alu_input_b,
            alu_op  => alu_control_signal,
            result  => alu_result,
            zero    => alu_zero
        );

    -- Data Memory
    data_mem: entity work.data_memory
        port map (
            clk              => clk,
            mem_read         => mem_read,
            mem_write        => mem_write,
            address          => alu_result,
            write_data       => rs2_data,
            read_data        => mem_read_data,
            gpio_read_data   => gpio_read_data,
            gpio_out_en      => gpio_out_en,
            gpio_in_en       => gpio_in_en,
            gpio_addr        => gpio_addr,
            gpio_write_data  => gpio_write_data
        );

    -- GPIO
    gpio_inst: entity work.gpio
        port map (
            clk         => clk,
            reset       => rst,
            write_en    => gpio_out_en,
            read_en     => gpio_in_en,
            addr        => gpio_addr,
            write_data  => gpio_write_data,
            read_data   => gpio_read_data,
            gpio_out    => gpio_out,
            gpio_toggle => gpio_toggle
        );

    -- Write-back mux
    write_back_data <= mem_read_data when mem_to_reg = '1' else alu_result;

    -- Next PC logic
    next_pc <= std_logic_vector(unsigned(pc) + 4);

end rtl;
