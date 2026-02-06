library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_register_file is
end tb_register_file;

architecture sim of tb_register_file is

    signal clk          : std_logic := '0';
    signal we           : std_logic := '0';
    signal rs1_addr     : std_logic_vector(4 downto 0);
    signal rs2_addr     : std_logic_vector(4 downto 0);
    signal rd_addr      : std_logic_vector(4 downto 0);
    signal rd_data_in   : std_logic_vector(31 downto 0);
    signal rs1_data_out : std_logic_vector(31 downto 0);
    signal rs2_data_out : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

    -- Procedure to generate a full clock cycle (rising and falling edge)
    procedure toggle_clk(signal clk : out std_logic) is
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end procedure;

begin

    -- Instantiate the register file under test
    uut: entity work.register_file
        port map (
            clk           => clk,
            we            => we,
            rs1_addr      => rs1_addr,
            rs2_addr      => rs2_addr,
            rd_addr       => rd_addr,
            rd_data_in    => rd_data_in,
            rs1_data_out  => rs1_data_out,
            rs2_data_out  => rs2_data_out
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Test 1: Write 0xAAAA5555 to register x5
        rd_addr     <= "00101"; -- x5
        rd_data_in  <= x"AAAA5555";
        we          <= '1';
        toggle_clk(clk); -- perform write on rising edge

        -- Read from x5 and check value
        we          <= '0';
        rs1_addr    <= "00101";
        wait for clk_period;
        assert rs1_data_out = x"AAAA5555"
        report "Error: x5 does not contain 0xAAAA5555 after write"
        severity error;

        -- Test 2: Attempt to write to register x0 (should be ignored)
        rd_addr     <= "00000"; -- x0
        rd_data_in  <= x"FFFFFFFF";
        we          <= '1';
        toggle_clk(clk);

        -- Read from x0 and check that it remains zero
        we          <= '0';
        rs1_addr    <= "00000";
        wait for clk_period;
        assert rs1_data_out = x"00000000"
        report "Error: x0 was modified but should always be zero"
        severity error;

        -- Test 3: Write 0x12345678 to register x10
        rd_addr     <= "01010"; -- x10
        rd_data_in  <= x"12345678";
        we          <= '1';
        toggle_clk(clk);

        -- Read from x10 and x5
        we          <= '0';
        rs1_addr    <= "01010"; -- x10
        rs2_addr    <= "00101"; -- x5
        wait for clk_period;

        assert rs1_data_out = x"12345678"
        report "Error: x10 does not contain 0x12345678"
        severity error;

        assert rs2_data_out = x"AAAA5555"
        report "Error: x5 does not contain 0xAAAA5555"
        severity error;

        report "All tests passed successfully!" severity note;
        wait;
    end process;

end sim;
