library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    Port (
        clk         : in  std_logic;
        mem_read    : in  std_logic;
        mem_write   : in  std_logic;
        address     : in  std_logic_vector(31 downto 0);
        write_data  : in  std_logic_vector(31 downto 0);
        read_data   : out std_logic_vector(31 downto 0);
        -- GPIO interface
        gpio_read_data : in  std_logic_vector(31 downto 0);
        gpio_out_en    : out std_logic;
        gpio_in_en     : out std_logic;
        gpio_addr      : out std_logic_vector(31 downto 0);
        gpio_write_data: out std_logic_vector(31 downto 0)
    );
end data_memory;

architecture Behavioral of data_memory is
    type ram_type is array (0 to 255) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    signal addr_index : integer range 0 to 255;
    signal is_gpio_access : std_logic;
begin

    addr_index <= to_integer(unsigned(address(9 downto 2))); -- Word-aligned addressing

    -- Detect GPIO access
    is_gpio_access <= '1' when (address = x"00000010" or address = x"00000014") else '0';

    -- GPIO control signals
    gpio_out_en     <= mem_write when address = x"00000010" else '0';
    gpio_in_en      <= mem_read  when address = x"00000014" else '0';
    gpio_addr       <= address;
    gpio_write_data <= write_data;

    -- RAM write
    process(clk)
    begin
        if rising_edge(clk) then
            if mem_write = '1' and is_gpio_access = '0' then
                ram(addr_index) <= write_data;
            end if;
        end if;
    end process;

    -- RAM/GPIO read
    process(mem_read, addr_index, is_gpio_access, gpio_read_data, ram)
    begin
        if mem_read = '1' then
            if is_gpio_access = '1' then
                read_data <= gpio_read_data;
            else
                read_data <= ram(addr_index);
            end if;
        else
            read_data <= (others => '0');
        end if;
    end process;

end Behavioral;
