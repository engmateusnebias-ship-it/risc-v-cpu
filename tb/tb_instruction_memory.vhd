library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_instruction_memory is
end tb_instruction_memory;

architecture sim of tb_instruction_memory is

    signal addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal instruction : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instantiate the instruction memory
    uut: entity work.instruction_memory
        port map (
            addr        => addr,
            instruction => instruction
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Test 1: Read instruction at address 0
        addr <= x"00000000";
        wait for clk_period;
        assert instruction = x"00000013"
        report "Error: Expected NOP at address 0"
        severity error;

        -- Test 2: Read instruction at address 4
        addr <= x"00000004";
        wait for clk_period;
        assert instruction = x"00500113"
        report "Error: Expected ADDI x2, x0, 5 at address 4"
        severity error;

        -- Test 3: Read instruction at address 8
        addr <= x"00000008";
        wait for clk_period;
        assert instruction = x"00208293"
        report "Error: Expected ADDI x5, x1, 2 at address 8"
        severity error;

        -- Test 4: Read instruction at address 12
        addr <= x"0000000C";
        wait for clk_period;
        assert instruction = x"00B50433"
        report "Error: Expected ADD x8, x10, x11 at address 12"
        severity error;

        -- Test 5: Read instruction at address 16
        addr <= x"00000010";
        wait for clk_period;
        assert instruction = x"0000006F"
        report "Error: Expected JAL x0, 0 at address 16"
        severity error;

        report "All instruction memory tests passed successfully!" severity note;
        wait;
    end process;

end sim;
