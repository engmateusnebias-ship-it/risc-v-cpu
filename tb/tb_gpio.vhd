library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Unit test for memory-mapped GPIO peripheral (VHDL-2002 compatible).
entity tb_gpio is
end tb_gpio;

architecture sim of tb_gpio is
    constant CLK_PERIOD : time := 10 ns;

    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';

    signal we          : std_logic := '0';
    signal re          : std_logic := '0';
    signal addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal wdata       : std_logic_vector(31 downto 0) := (others => '0');
    signal wstrb       : std_logic_vector(3 downto 0)  := (others => '0');
    signal rdata       : std_logic_vector(31 downto 0);

    signal gpio_out    : std_logic_vector(3 downto 0);
    signal gpio_toggle : std_logic := '0';

begin

    uut: entity work.gpio
        port map (
            clk         => clk,
            rst         => rst,
            we          => we,
            re          => re,
            addr        => addr,
            wdata       => wdata,
            wstrb       => wstrb,
            rdata       => rdata,
            gpio_out    => gpio_out,
            gpio_toggle => gpio_toggle
        );

    -- Free-running clock
    clk_gen: process
    begin
        while now < 500 ns loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stim: process
    begin
        -- Apply reset
        rst <= '1';
        wait for 2*CLK_PERIOD;
        rst <= '0';
        wait until rising_edge(clk);

        -- After reset, GPIO_OUT must be 0.
        assert gpio_out = "0000" report "GPIO reset value incorrect" severity failure;

        -- Write 0xA to GPIO_OUT (0x10). Only lane 0 is used.
        addr  <= x"00000010";
        wdata <= x"0000000A";
        wstrb <= "0001";
        we    <= '1';
        wait until rising_edge(clk);
        we    <= '0';
        wstrb <= (others => '0');
        wait for 1 ns; -- allow signal update
        assert gpio_out = "1010" report "GPIO write failed" severity failure;

        -- Read back GPIO_OUT
        addr <= x"00000010";
        re   <= '1';
        wait for 1 ns; -- combinational read path
        assert rdata(3 downto 0) = "1010" report "GPIO readback of OUT failed" severity failure;
        re   <= '0';

        -- Read GPIO_IN reflects gpio_toggle (0x14)
        gpio_toggle <= '1';
        addr <= x"00000014";
        re   <= '1';
        wait for 1 ns;
        assert rdata(0) = '1' report "GPIO IN read failed (toggle=1)" severity failure;
        re   <= '0';

        gpio_toggle <= '0';
        addr <= x"00000014";
        re   <= '1';
        wait for 1 ns;
        assert rdata(0) = '0' report "GPIO IN read failed (toggle=0)" severity failure;
        re   <= '0';

        report "tb_gpio: all tests passed." severity note;
        wait;
    end process;

end sim;
