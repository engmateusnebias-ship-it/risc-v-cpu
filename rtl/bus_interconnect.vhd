library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Simple single-cycle interconnect for memory-mapped peripherals.
-- Address map (byte addresses):
--  - 0x0000_0000 .. 0x0000_03FF : Data RAM (256 words)
--  - 0x0000_0010 : GPIO_OUT (write)
--  - 0x0000_0014 : GPIO_IN  (read)
--  - 0x0000_0020 : TIMER_COUNT (read)
--  - 0x0000_0024 : TIMER_CMP   (read/write)
--  - 0x0000_0028 : TIMER_CTRL  (read/write)
entity bus_interconnect is
    Port (
        -- CPU bus
        addr        : in  std_logic_vector(31 downto 0);
        we          : in  std_logic;
        re          : in  std_logic;
        wdata       : in  std_logic_vector(31 downto 0);
        wstrb       : in  std_logic_vector(3 downto 0);
        rdata       : out std_logic_vector(31 downto 0);

        -- Data RAM
        ram_we      : out std_logic;
        ram_re      : out std_logic;
        ram_addr    : out std_logic_vector(31 downto 0);
        ram_wdata   : out std_logic_vector(31 downto 0);
        ram_wstrb   : out std_logic_vector(3 downto 0);
        ram_rdata   : in  std_logic_vector(31 downto 0);

        -- GPIO
        gpio_we     : out std_logic;
        gpio_re     : out std_logic;
        gpio_addr   : out std_logic_vector(31 downto 0);
        gpio_wdata  : out std_logic_vector(31 downto 0);
        gpio_wstrb  : out std_logic_vector(3 downto 0);
        gpio_rdata  : in  std_logic_vector(31 downto 0);

        -- TIMER
        timer_we    : out std_logic;
        timer_re    : out std_logic;
        timer_addr  : out std_logic_vector(31 downto 0);
        timer_wdata : out std_logic_vector(31 downto 0);
        timer_wstrb : out std_logic_vector(3 downto 0);
        timer_rdata : in  std_logic_vector(31 downto 0)
    );
end bus_interconnect;

architecture rtl of bus_interconnect is
    signal is_ram   : std_logic;
    signal is_gpio  : std_logic;
    signal is_timer : std_logic;
begin
    -- Decode (simple, exact match for GPIO/TIMER registers)
    is_gpio  <= '1' when (addr = x"00000010" or addr = x"00000014") else '0';
    is_timer <= '1' when (addr = x"00000020" or addr = x"00000024" or addr = x"00000028") else '0';
    is_ram   <= '1' when (is_gpio = '0' and is_timer = '0') else '0';

    -- Fanout
    ram_addr  <= addr;
    ram_wdata <= wdata;
    ram_wstrb <= wstrb;
    ram_we    <= we and is_ram;
    ram_re    <= re and is_ram;

    gpio_addr  <= addr;
    gpio_wdata <= wdata;
    gpio_wstrb <= wstrb;
    gpio_we    <= we and is_gpio;
    gpio_re    <= re and is_gpio;

    timer_addr  <= addr;
    timer_wdata <= wdata;
    timer_wstrb <= wstrb;
    timer_we    <= we and is_timer;
    timer_re    <= re and is_timer;

    -- Read mux
    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(re, addr, is_gpio, is_timer, gpio_rdata, timer_rdata, ram_rdata)
    begin
        rdata <= (others => '0');
        if re = '1' then
            if is_gpio = '1' then
                rdata <= gpio_rdata;
            elsif is_timer = '1' then
                rdata <= timer_rdata;
            else
                rdata <= ram_rdata;
            end if;
        end if;
    end process;
end rtl;
