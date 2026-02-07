library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    Port (
        clk   : in  std_logic;
        reset : in  std_logic
    );
end cpu;

architecture Behavioral of cpu is

    -- Signals
    signal pc              : std_logic_vector(31 downto 0);
    signal next_pc         : std_logic_vector(31 downto 0);
    signal instruction     : std_logic_vector(31 downto 0);
    signal rs1_addr        : std_logic_vector(4 downto 0);
    signal rs2_addr        : std_logic_vector(4 downto 0);
    signal rd_addr         : std_logic_vector(4 downto 0);
    signal rs1_data        : std_logic_vector(31 downto 0);
    signal rs2_data        : std_logic_vector(31 downto 0);
    signal imm             : std_logic_vector(31 downto 0);
    signal alu_input_b     : std_logic_vector(31 downto 0);
    signal alu_result      : std_logic_vector(31 downto 0);
    signal zero_flag       : std_logic;
    signal mem_read_data   : std_logic_vector(31 downto 0);
    signal write_back_data : std_logic_vector(31 downto 0);

    -- Control signals
    signal reg_write    : std_logic;
    signal alu_src      : std_logic;
    signal mem_read     : std_logic;
    signal mem_write    : std_logic;
    signal mem_to_reg   : std_logic;
    signal branch       : std_logic;
    signal jump         : std_logic;
    signal alu_op_ctrl  : std_logic_vector(1 downto 0);
    signal alu_control  : std_logic_vector(3 downto 0);

begin

    -- Program Counter
    process(clk, reset)
    begin
        if reset = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            pc <= next_pc;
        end if;
    end process;

    -- Next PC logic
    next_pc <= std_logic_vector(unsigned(pc) + 4);

    -- Instruction Memory
    instr_mem: entity work.instruction_memory
        port map (
            address     => pc,
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

    -- Immediate Generator
    imm_gen: entity work.immediate_generator
        port map (
            instr   => instruction,
            imm_out => imm
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

    -- ALU Control
    alu_ctrl: entity work.alu_control
        port map (
            alu_op_ctrl        => alu_op_ctrl,
            funct3             => instruction(14 downto 12),
            funct7             => instruction(31 downto 25),
            alu_control_signal => alu_control
        );

    -- ALU input mux
    alu_input_b <= imm when alu_src = '1' else rs2_data;

    -- ALU
    alu_inst: entity work.alu
        port map (
            A      => rs1_data,
            B      => alu_input_b,
            alu_op => alu_control,
            result => alu_result,
            zero   => zero_flag
        );

    -- Data Memory
    data_mem: entity work.data_memory
        port map (
            clk         => clk,
            mem_read    => mem_read,
            mem_write   => mem_write,
            address     => alu_result,
            write_data  => rs2_data,
            read_data   => mem_read_data
        );

    -- Write-back mux
    write_back_data <= mem_read_data when mem_to_reg = '1' else alu_result;

end Behavioral;
