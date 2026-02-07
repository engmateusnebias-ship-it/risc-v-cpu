library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    Port (
        clk       : in  std_logic;
        mem_read  : in  std_logic;
        mem_write : in  std_logic;
        address   : in  std_logic_vector(31 downto 0);
        write_data: in  std_logic_vector(31 downto 0);
        read_data : out std_logic_vector(31 downto 0)
    );
end data_memory;

architecture Behavioral of data_memory is
    type ram_type is array (0 to 255) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    signal addr_index : integer range 0 to 255;
begin

    addr_index <= to_integer(unsigned(address(9 downto 2))); -- Word-aligned addressing

    process(clk)
    begin
        if rising_edge(clk) then
            if mem_write = '1' then
                ram(addr_index) <= write_data;
            end if;
        end if;
    end process;

    process(mem_read, addr_index)
    begin
        if mem_read = '1' then
            read_data <= ram(addr_index);
        else
            read_data <= (others => '0');
        end if;
    end process;

end Behavioral;
