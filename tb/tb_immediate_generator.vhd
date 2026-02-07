library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_immediate_generator is
end tb_immediate_generator;

architecture sim of tb_immediate_generator is

    signal instr   : std_logic_vector(31 downto 0);
    signal imm_out : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: entity work.immediate_generator
        port map (
            instr   => instr,
            imm_out => imm_out
        );

    stim_proc: process
    begin
        -- I-type: ADDI x1, x0, -1 => imm = 0xFFFFFFFF
        instr <= x"FFF00093"; -- opcode = 0010011
        wait for clk_period;
        assert imm_out = x"FFFFFFFF"
        report "Error: I-type immediate not extracted correctly"
        severity error;

        -- S-type: SW x2, -4(x1) => imm = 0xFFFFFFE4
        instr <= x"FEA02223"; -- opcode = 0100011
        wait for clk_period;
        assert imm_out = x"FFFFFFE4"
        report "Error: S-type immediate not extracted correctly"
        severity error;

        -- B-type: BEQ x1, x2, 8 => imm = 0x0000000C
        instr <= x"00208663"; -- opcode = 1100011
        wait for clk_period;
        assert imm_out = x"0000000C"
        report "Error: B-type immediate not extracted correctly"
        severity error;

        -- U-type: LUI x1, 0x12345 => imm = 0x12345000
        instr <= x"123450B7"; -- opcode = 0110111
        wait for clk_period;
        assert imm_out = x"12345000"
        report "Error: U-type immediate not extracted correctly"
        severity error;

        -- J-type: JAL x0, 16 => imm = 0x00000010
        instr <= x"0100006F"; -- opcode = 1101111
        wait for clk_period;
        assert imm_out = x"00000010"
        report "Error: J-type immediate not extracted correctly"
        severity error;

        report "All immediate generator tests passed successfully!" severity note;
        wait;
    end process;

end sim;
