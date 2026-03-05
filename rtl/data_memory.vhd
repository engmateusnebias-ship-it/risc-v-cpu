library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Simple 256-word data RAM with byte write strobes.
-- Addressing is byte-based; internally word index uses addr[9:2].
entity data_memory is
    Port (
        clk       : in  std_logic;
        we        : in  std_logic;
        re        : in  std_logic;
        addr      : in  std_logic_vector(31 downto 0);
        wdata     : in  std_logic_vector(31 downto 0);
        wstrb     : in  std_logic_vector(3 downto 0);
        rdata     : out std_logic_vector(31 downto 0)
    );
end data_memory;

architecture rtl of data_memory is
    type ram_type is array (0 to 255) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    signal idx : integer range 0 to 255;
    signal word_q : std_logic_vector(31 downto 0);
begin
    idx <= to_integer(unsigned(addr(9 downto 2)));

    -- Synchronous write with byte enables
    process(clk)
        variable tmp : std_logic_vector(31 downto 0);
    begin
        if rising_edge(clk) then
            if we = '1' then
                tmp := ram(idx);
                if wstrb(0) = '1' then tmp(7 downto 0)   := wdata(7 downto 0); end if;
                if wstrb(1) = '1' then tmp(15 downto 8)  := wdata(15 downto 8); end if;
                if wstrb(2) = '1' then tmp(23 downto 16) := wdata(23 downto 16); end if;
                if wstrb(3) = '1' then tmp(31 downto 24) := wdata(31 downto 24); end if;
                ram(idx) <= tmp;
            end if;
        end if;
    end process;

    -- Combinational read (single-cycle)
    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(re, idx, ram)
    begin
        if re = '1' then
            rdata <= ram(idx);
        else
            rdata <= (others => '0');
        end if;
    end process;
end rtl;
