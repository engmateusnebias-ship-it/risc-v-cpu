library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_data_memory is
end tb_data_memory;

architecture tb of tb_data_memory is
    signal clk   : std_logic := '0';
    signal we    : std_logic := '0';
    signal re    : std_logic := '0';
    signal addr  : std_logic_vector(31 downto 0) := (others => '0');
    signal wdata : std_logic_vector(31 downto 0) := (others => '0');
    signal wstrb : std_logic_vector(3 downto 0) := (others => '0');
    signal rdata : std_logic_vector(31 downto 0);

    -- Wait for one rising edge of clk (VHDL-93/2002 compatible)
    procedure tick(signal c : in std_logic) is
    begin
        wait until rising_edge(c);
    end procedure;

    procedure check(cond : boolean; msg : string) is
    begin
        assert cond report msg severity failure;
    end procedure;
begin
    -- Free-running clock
    clk_gen: process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    dut: entity work.data_memory
        port map (
            clk   => clk,
            we    => we,
            re    => re,
            addr  => addr,
            wdata => wdata,
            wstrb => wstrb,
            rdata => rdata
        );

    stim: process
    begin
        -- Full word write/read
        addr  <= x"00000000";
        wdata <= x"11223344";
        wstrb <= "1111";
        we    <= '1';
        re    <= '0';
        tick(clk);
        we <= '0';

        re <= '1';
        wait for 1 ns;
        check(rdata = x"11223344", "Word readback failed");
        re <= '0';

        -- Byte write: update byte lane 2 (addr+2)
        addr  <= x"00000002";
        wdata <= x"00AA0000"; -- only lane2 used by wstrb(2)
        wstrb <= "0100";
        we    <= '1';
        tick(clk);
        we    <= '0';
        wstrb <= "0000";

        -- Read back full word
        addr <= x"00000000";
        re   <= '1';
        wait for 1 ns;
        check(rdata = x"11AA3344", "Byte write (lane2) failed");
        re <= '0';

        -- Halfword write: update upper halfword (addr+2)
        addr  <= x"00000002";
        wdata <= x"BEEF0000";
        wstrb <= "1100";
        we    <= '1';
        tick(clk);
        we <= '0';

        addr <= x"00000000";
        re   <= '1';
        wait for 1 ns;
        check(rdata = x"BEEF3344", "Halfword write failed");
        re <= '0';

        -- No write strobes: must not change memory
        addr  <= x"00000000";
        wdata <= x"FFFFFFFF";
        wstrb <= "0000";
        we    <= '1';
        tick(clk);
        we <= '0';

        re <= '1';
        wait for 1 ns;
        check(rdata = x"BEEF3344", "Write with wstrb=0000 should not modify memory");
        re <= '0';

        report "tb_data_memory: ALL TESTS PASSED" severity note;
        wait;
    end process;
end tb;
