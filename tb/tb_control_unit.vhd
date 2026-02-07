library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_control_unit is
end tb_control_unit;

architecture sim of tb_control_unit is
    constant clk_period : time := 10 ns;

    signal instr        : std_logic_vector(31 downto 0);
    signal reg_write    : std_logic;
    signal alu_src      : std_logic;
    signal mem_read     : std_logic;
    signal mem_write    : std_logic;
    signal mem_to_reg   : std_logic;
    signal branch       : std_logic;
    signal jump         : std_logic;
    signal alu_op_ctrl  : std_logic_vector(1 downto 0);
begin
    uut: entity work.control_unit
        port map (
            instr        => instr,
            reg_write    => reg_write,
            alu_src      => alu_src,
            mem_read     => mem_read,
            mem_write    => mem_write,
            mem_to_reg   => mem_to_reg,
            branch       => branch,
            jump         => jump,
            alu_op_ctrl  => alu_op_ctrl
        );

    stim_proc: process
    begin
        -- R-type: ADD
        instr <= x"00B50633"; wait for clk_period;
        assert reg_write = '1' and alu_src = '0' and alu_op_ctrl = "10"
        report "R-type ADD failed" severity error;

        -- I-type: SLTI
        instr <= x"0022A213"; wait for clk_period;
        assert reg_write = '1' and alu_src = '1' and alu_op_ctrl = "00"
        report "I-type SLTI failed" severity error;

        -- LW
        instr <= x"00012303"; wait for clk_period;
        assert mem_read = '1' and mem_to_reg = '1' and alu_src = '1'
        report "LW failed" severity error;

        -- SW
        instr <= x"00A12023"; wait for clk_period;
        assert mem_write = '1' and alu_src = '1' and reg_write = '0'
        report "SW failed" severity error;

        -- BEQ
        instr <= x"00A50863"; wait for clk_period;
        assert branch = '1' and alu_op_ctrl = "01"
        report "BEQ failed" severity error;

        -- JAL
        instr <= x"0000006F"; wait for clk_period;
        assert jump = '1' and reg_write = '1'
        report "JAL failed" severity error;

        -- LUI
        instr <= x"000000B7"; wait for clk_period;
        assert reg_write = '1' and alu_op_ctrl = "11"
        report "LUI failed" severity error;

        -- Invalid opcode
        instr <= x"FFFFFFFF"; wait for clk_period;
        assert reg_write = '0' and mem_read = '0' and mem_write = '0' and branch = '0'
        report "Invalid opcode handling failed" severity error;

        report "All control unit tests passed." severity note;
        wait;
    end process;
end sim;
