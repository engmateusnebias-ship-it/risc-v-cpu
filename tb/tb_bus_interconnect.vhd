library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_bus_interconnect is
end tb_bus_interconnect;

architecture tb of tb_bus_interconnect is
    signal addr  : std_logic_vector(31 downto 0);
    signal we, re : std_logic;
    signal wdata : std_logic_vector(31 downto 0);
    signal wstrb : std_logic_vector(3 downto 0);
    signal rdata : std_logic_vector(31 downto 0);

    signal ram_we, ram_re : std_logic;
    signal ram_addr : std_logic_vector(31 downto 0);
    signal ram_wdata : std_logic_vector(31 downto 0);
    signal ram_wstrb : std_logic_vector(3 downto 0);
    signal ram_rdata : std_logic_vector(31 downto 0);

    signal gpio_we, gpio_re : std_logic;
    signal gpio_addr : std_logic_vector(31 downto 0);
    signal gpio_wdata : std_logic_vector(31 downto 0);
    signal gpio_wstrb : std_logic_vector(3 downto 0);
    signal gpio_rdata : std_logic_vector(31 downto 0);

    signal timer_we, timer_re : std_logic;
    signal timer_addr : std_logic_vector(31 downto 0);
    signal timer_wdata : std_logic_vector(31 downto 0);
    signal timer_wstrb : std_logic_vector(3 downto 0);
    signal timer_rdata : std_logic_vector(31 downto 0);

    procedure check(cond : boolean; msg : string) is
    begin
        assert cond report msg severity failure;
    end procedure;
begin
    dut: entity work.bus_interconnect
        port map (
            addr        => addr,
            we          => we,
            re          => re,
            wdata       => wdata,
            wstrb       => wstrb,
            rdata       => rdata,

            ram_we      => ram_we,
            ram_re      => ram_re,
            ram_addr    => ram_addr,
            ram_wdata   => ram_wdata,
            ram_wstrb   => ram_wstrb,
            ram_rdata   => ram_rdata,

            gpio_we     => gpio_we,
            gpio_re     => gpio_re,
            gpio_addr   => gpio_addr,
            gpio_wdata  => gpio_wdata,
            gpio_wstrb  => gpio_wstrb,
            gpio_rdata  => gpio_rdata,

            timer_we    => timer_we,
            timer_re    => timer_re,
            timer_addr  => timer_addr,
            timer_wdata => timer_wdata,
            timer_wstrb => timer_wstrb,
            timer_rdata => timer_rdata
        );

    process
    begin
        -- Default read sources
        ram_rdata <= x"AAAAAAAA";
        gpio_rdata <= x"BBBBBBBB";
        timer_rdata <= x"CCCCCCCC";

        -- Read RAM
        addr <= x"00000000"; re <= '1'; we <= '0'; wdata <= (others=>'0'); wstrb <= "0000";
        wait for 1 ns;
        check(ram_re='1' and rdata=x"AAAAAAAA", "RAM read mux failed");

        -- Read GPIO
        addr <= x"00000014"; re <= '1';
        wait for 1 ns;
        check(gpio_re='1' and rdata=x"BBBBBBBB", "GPIO read mux failed");

        -- Read TIMER
        addr <= x"00000020"; re <= '1';
        wait for 1 ns;
        check(timer_re='1' and rdata=x"CCCCCCCC", "TIMER read mux failed");

        -- Write GPIO
        re <= '0'; we <= '1'; addr <= x"00000010"; wdata <= x"0000000F"; wstrb <= "1111";
        wait for 1 ns;
        check(gpio_we='1' and ram_we='0' and timer_we='0', "GPIO write decode failed");

        report "tb_bus_interconnect PASSED" severity note;
        wait;
    end process;
end tb;
