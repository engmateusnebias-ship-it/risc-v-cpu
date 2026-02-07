library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_data_memory is
end tb_data_memory;

architecture sim of tb_data_memory is

    signal clk        : std_logic := '0';
    signal mem_read   : std_logic;
    signal mem_write  : std_logic;
    signal address    : std_logic_vector(31 downto 0);
    signal write_data : std_logic_vector(31 downto 0);
    signal read_data  : std_logic_vector(31 downto 0);

begin

    uut: entity work.data_memory
        port map (
            clk        => clk,
            mem_read   => mem_read,
            mem_write  => mem_write,
            address    => address,
            write_data => write_data,
            read_data  => read_data
        );

    clk_process: process
    begin
        while now < 200 ns loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
        -- Write 0xDEADBEEF to address 0x00000010
        mem_read   <= '0';
        mem_write  <= '1';
        address    <= x"00000010";
        write_data <= x"DEADBEEF";
        wait for 10 ns;

        -- Disable write
        mem_write <= '0';
        wait for 10 ns;

        -- Read from address 0x00000010
        mem_read <= '1';
        wait for 10 ns;
        assert read_data = x"DEADBEEF" report "Read failed at address 0x10" severity error;

        -- Read from address 0x00000014 (should be zero)
        address <= x"00000014";
        wait for 10 ns;
        assert read_data = x"00000000" report "Unexpected data at address 0x14" severity error;

        report "All data memory tests passed." severity note;
        wait;
    end process;

end sim;
