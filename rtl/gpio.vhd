library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Memory-mapped GPIO peripheral.
-- Address map:
--  - 0x0000_0010 GPIO_OUT (RW) : bits[3:0] drive gpio_out
--  - 0x0000_0014 GPIO_IN  (RO) : bit0 reflects gpio_toggle
entity gpio is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        we          : in  std_logic;
        re          : in  std_logic;
        addr        : in  std_logic_vector(31 downto 0);
        wdata       : in  std_logic_vector(31 downto 0);
        wstrb       : in  std_logic_vector(3 downto 0);
        rdata       : out std_logic_vector(31 downto 0);

        gpio_out    : out std_logic_vector(3 downto 0);
        gpio_toggle : in  std_logic
    );
end gpio;

architecture rtl of gpio is
    signal out_reg : std_logic_vector(3 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            out_reg <= (others => '0');
        elsif rising_edge(clk) then
            if we = '1' and addr = x"00000010" then
                -- Only byte lane 0 affects bits[7:0]; we use bits[3:0].
                if wstrb(0) = '1' then
                    out_reg <= wdata(3 downto 0);
                end if;
            end if;
        end if;
    end process;

    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(re, addr, out_reg, gpio_toggle)
    begin
        rdata <= (others => '0');
        if re = '1' then
            if addr = x"00000010" then
                rdata <= (31 downto 4 => '0') & out_reg;
            elsif addr = x"00000014" then
                rdata <= (31 downto 1 => '0') & gpio_toggle;
            else
                rdata <= (others => '0');
            end if;
        end if;
    end process;

    gpio_out <= out_reg;
end rtl;
