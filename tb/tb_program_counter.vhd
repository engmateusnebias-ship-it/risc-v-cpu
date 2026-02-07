library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_program_counter is
end tb_program_counter;

architecture sim of tb_program_counter is

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal enable   : std_logic := '0';
    signal next_pc  : std_logic_vector(31 downto 0) := (others => '0');
    signal pc       : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

    -- Clock generator
    procedure toggle_clk(signal clk : out std_logic) is
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end procedure;

begin

    -- Instantiate the Program Counter
    uut: entity work.program_counter
        port map (
            clk     => clk,
            rst     => rst,
            enable  => enable,
            next_pc => next_pc,
            pc      => pc
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Test 1: Reset PC
        rst <= '1';
        enable <= '1';
        next_pc <= x"00000004";
        toggle_clk(clk);
        rst <= '0';
        wait for clk_period;
        assert pc = x"00000000"
        report "Error: PC should be 0 after reset"
        severity error;

        -- Test 2: Load PC with 0x00000004
        next_pc <= x"00000004";
        enable <= '1';
        toggle_clk(clk);
        wait for clk_period;
        assert pc = x"00000004"
        report "Error: PC should be 0x00000004"
        severity error;

        -- Test 3: Stall PC (enable = 0), PC should hold its value
        enable <= '0';
        next_pc <= x"00000008";
        toggle_clk(clk);
        wait for clk_period;
        assert pc = x"00000004"
        report "Error: PC should not change when enable = 0"
        severity error;

        -- Test 4: Load PC with 0x00000010
        enable <= '1';
        next_pc <= x"00000010";
        toggle_clk(clk);
        wait for clk_period;
        assert pc = x"00000010"
        report "Error: PC should be 0x00000010"
        severity error;

        report "All PC tests passed successfully!" severity note;
        wait;
    end process;

end sim;
