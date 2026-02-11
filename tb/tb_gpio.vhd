library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_gpio is
end tb_gpio;

architecture sim of tb_gpio is
    constant clk_period : time := 10 ns;

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal write_en    : std_logic;
    signal read_en     : std_logic;
    signal addr        : std_logic_vector(31 downto 0);
    signal write_data  : std_logic_vector(31 downto 0);
    signal read_data   : std_logic_vector(31 downto 0);
    signal gpio_out    : std_logic_vector(3 downto 0);
    signal gpio_toggle : std_logic := '0';

begin

    uut: entity work.gpio
        port map (
            clk         => clk,
            reset       => reset,
            write_en    => write_en,
            read_en     => read_en,
            addr        => addr,
            write_data  => write_data,
            read_data   => read_data,
            gpio_out    => gpio_out,
            gpio_toggle => gpio_toggle
        );

    clk_process: process
    begin
        while now < 200 ns loop
            clk <= '0'; wait for clk_period / 2;
            clk <= '1'; wait for clk_period / 2;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
        -- Reset
        reset <= '1'; wait for clk_period;
        reset <= '0'; wait for clk_period;

        -- Write 0b1010 to GPIO output (LEDs)
        addr       <= x"00000010";
        write_data <= x"0000000A";
        write_en   <= '1';
        wait for clk_period;
        write_en   <= '0';
        wait for clk_period;
        assert gpio_out = "1010" report "GPIO write failed" severity error;

        -- Simulate toggle button = 1
        gpio_toggle <= '1';
        addr        <= x"00000014";
        read_en     <= '1';
        wait for clk_period;
        assert read_data(0) = '1' report "GPIO read failed (toggle=1)" severity error;

        -- Simulate toggle button = 0
        gpio_toggle <= '0';
        wait for clk_period;
        assert read_data(0) = '0' report "GPIO read failed (toggle=0)" severity error;

        report "All GPIO tests passed." severity note;
        wait;
    end process;

end sim;
