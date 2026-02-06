library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    Port (
        clk           : in  std_logic;
        we            : in  std_logic;
        rs1_addr      : in  std_logic_vector(4 downto 0);
        rs2_addr      : in  std_logic_vector(4 downto 0);
        rd_addr       : in  std_logic_vector(4 downto 0);
        rd_data_in    : in  std_logic_vector(31 downto 0);
        rs1_data_out  : out std_logic_vector(31 downto 0);
        rs2_data_out  : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture Behavioral of register_file is
    type reg_array is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));
begin

    -- Read ports (combinational)
    rs1_data_out <= (others => '0') when rs1_addr = "00000" else regs(to_integer(unsigned(rs1_addr)));
    rs2_data_out <= (others => '0') when rs2_addr = "00000" else regs(to_integer(unsigned(rs2_addr)));

    -- Write port (synchronous)
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and rd_addr /= "00000" then
                regs(to_integer(unsigned(rd_addr))) <= rd_data_in;
            end if;
        end if;
    end process;

end Behavioral;
