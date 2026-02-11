library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gpio is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        write_en    : in  std_logic;
        read_en     : in  std_logic;
        addr        : in  std_logic_vector(31 downto 0);
        write_data  : in  std_logic_vector(31 downto 0);
        read_data   : out std_logic_vector(31 downto 0);
        gpio_out    : out std_logic_vector(3 downto 0);
        gpio_toggle : in  std_logic
    );
end gpio;

architecture Behavioral of gpio is
    signal led_reg : std_logic_vector(3 downto 0) := (others => '0');
begin

    -- Write process
    process(clk, reset)
    begin
        if reset = '1' then
            led_reg <= (others => '0');
        elsif rising_edge(clk) then
            if write_en = '1' and addr = x"00000010" then
                led_reg <= write_data(3 downto 0);
            end if;
        end if;
    end process;

    -- Read logic
    process(read_en, addr, gpio_toggle)
    begin
        if read_en = '1' and addr = x"00000014" then
            read_data <= (31 downto 1 => '0') & gpio_toggle;
        else
            read_data <= (others => '0');
        end if;
    end process;

    gpio_out <= led_reg;

end Behavioral;
