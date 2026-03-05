library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_timer is
end tb_timer;

architecture tb of tb_timer is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal we, re : std_logic := '0';
    signal addr : std_logic_vector(31 downto 0) := (others => '0');
    signal wdata : std_logic_vector(31 downto 0) := (others => '0');
    signal wstrb : std_logic_vector(3 downto 0) := (others => '0');
    signal rdata : std_logic_vector(31 downto 0);
    signal irq : std_logic;

    -- Wait for N rising edges of clk.
    procedure tick(n : natural := 1) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

    procedure check(cond : boolean; msg : string) is
    begin
        assert cond report msg severity failure;
    end procedure;
begin

    -- Free-running clock generator (10 ns period).
    clk_gen : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    dut: entity work.timer
        port map (
            clk   => clk,
            rst   => rst,
            we    => we,
            re    => re,
            addr  => addr,
            wdata => wdata,
            wstrb => wstrb,
            rdata => rdata,
            irq   => irq
        );

    stim : process
    begin
        -- Reset
        tick(2);
        rst <= '0';
        tick(2);

        -- Program compare value to 3
        addr  <= x"00000024";
        wdata <= x"00000003";
        wstrb <= "1111";
        we    <= '1';
        tick(1);
        we    <= '0';
        wstrb <= (others => '0');

        -- Enable timer and IRQ (CTRL bit0=enable, bit1=irq_en)
        addr  <= x"00000028";
        wdata <= x"00000003";
        wstrb <= "0001";
        we    <= '1';
        tick(1);
        we    <= '0';
        wstrb <= (others => '0');

        -- Wait a few cycles; IRQ should assert when count == cmp
        tick(4);
        check(irq = '1', "IRQ should assert at count==cmp");

        -- Read COUNT
        addr <= x"00000020";
        re   <= '1';
        wait for 1 ns; -- allow combinational read
        -- Depending on exact cycle, count could be 3..6 here. Accept a small range.
        check(unsigned(rdata) >= 3 and unsigned(rdata) <= 6, "COUNT read seems wrong");
        re <= '0';

        report "tb_timer PASSED" severity note;
        wait;
    end process;
end tb;
