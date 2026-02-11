library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_data_memory is
end tb_data_memory;

architecture sim of tb_data_memory is
    signal clk             : std_logic := '0';
    signal mem_read        : std_logic;
    signal mem_write       : std_logic;
    signal address         : std_logic_vector(31 downto 0);
    signal write_data      : std_logic_vector(31 downto 0);
    signal read_data       : std_logic_vector(31 downto 0);
    signal gpio_read_data  : std_logic_vector(31 downto 0);
    signal gpio_out_en     : std_logic;
    signal gpio_in_en      : std_logic;
    signal gpio_addr       : std_logic_vector(31 downto 0);
    signal gpio_write_data : std_logic_vector(31 downto 0);
begin

    uut: entity work.data_memory
        port map (
            clk             => clk,
            mem_read        => mem_read,
            mem_write       => mem_write,
            address         => address,
            write_data      => write_data,
            read_data       => read_data,
            gpio_read_data  => gpio_read_data,
            gpio_out_en     => gpio_out_en,
            gpio_in_en      => gpio_in_en,
            gpio_addr       => gpio_addr,
            gpio_write_data => gpio_write_data
        );

    clk_process: process
    begin
        while now < 300 ns loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
        -- Write to RAM at address 0x00000020
        mem_read   <= '0';
        mem_write  <= '1';
        address    <= x"00000020";
        write_data <= x"DEADBEEF";
        wait for 10 ns;

        -- Disable write
        mem_write <= '0';
        wait for 10 ns;

        -- Read from RAM at address 0x00000020
        mem_read <= '1';
        wait for 10 ns;
        assert read_data = x"DEADBEEF" report "RAM read failed at 0x20" severity error;

        -- Read from GPIO input (simulate toggle = '1')
        address         <= x"00000014";
        gpio_read_data  <= x"00000001";
        wait for 10 ns;
        assert read_data = x"00000001" and gpio_in_en = '1'
        report "GPIO read failed (toggle=1)" severity error;

        -- Write to GPIO output
        mem_read   <= '0';
        mem_write  <= '1';
        address    <= x"00000010";
        write_data <= x"0000000F";
        wait for 10 ns;
        assert gpio_out_en = '1' and gpio_write_data(3 downto 0) = "1111"
        report "GPIO write failed (LEDs)" severity error;

        report "All data memory + GPIO integration tests passed." severity note;
        wait;
    end process;

end sim;
