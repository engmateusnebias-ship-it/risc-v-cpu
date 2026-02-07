library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_decoder is
end tb_decoder;

architecture sim of tb_decoder is
    constant clk_period : time := 10 ns;

    signal instr      : std_logic_vector(31 downto 0);
    signal alu_op     : std_logic_vector(3 downto 0);
    signal reg_write  : std_logic;
    signal mem_read   : std_logic;
    signal mem_write  : std_logic;
    signal mem_to_reg : std_logic;
    signal alu_src    : std_logic;
    signal branch     : std_logic;
    signal jump       : std_logic;

    component decoder
        Port (
            instr      : in  std_logic_vector(31 downto 0);
            alu_op     : out std_logic_vector(3 downto 0);
            reg_write  : out std_logic;
            mem_read   : out std_logic;
            mem_write  : out std_logic;
            mem_to_reg : out std_logic;
            alu_src    : out std_logic;
            branch     : out std_logic;
            jump       : out std_logic
        );
    end component;
begin
    uut: decoder
        port map (
            instr      => instr,
            alu_op     => alu_op,
            reg_write  => reg_write,
            mem_read   => mem_read,
            mem_write  => mem_write,
            mem_to_reg => mem_to_reg,
            alu_src    => alu_src,
            branch     => branch,
            jump       => jump
        );

    stimulus: process
    begin
        -- AND (R-type)
        instr <= x"00F777B3"; wait for clk_period;
        assert alu_op = "1010" and reg_write = '1' and alu_src = '0'
        report "AND failed" severity error;

        -- ORI (I-type)
        instr <= x"00F7E793"; wait for clk_period;
        assert alu_op = "1001" and reg_write = '1' and alu_src = '1'
        report "ORI failed" severity error;

        -- SLL (R-type)
        instr <= x"00F717B3"; wait for clk_period;
        assert alu_op = "0011" and reg_write = '1' and alu_src = '0'
        report "SLL failed" severity error;

        -- SRLI (I-type)
        instr <= x"00F75793"; wait for clk_period;
        assert alu_op = "0111" and reg_write = '1' and alu_src = '1'
        report "SRLI failed" severity error;

        -- SRA (R-type)
        instr <= x"40F757B3"; wait for clk_period;
        assert alu_op = "1000" and reg_write = '1' and alu_src = '0'
        report "SRA failed" severity error;

        -- LW (I-type)
        instr <= x"0007A303"; wait for clk_period;
        assert alu_op = "0000" and mem_read = '1' and mem_to_reg = '1' and reg_write = '1' and alu_src = '1'
        report "LW failed" severity error;

        -- SW (S-type)
        instr <= x"00A32023"; wait for clk_period;
        assert alu_op = "0000" and mem_write = '1' and alu_src = '1' and reg_write = '0'
        report "SW failed" severity error;

        -- BEQ (B-type)
        instr <= x"00A30663"; wait for clk_period;
        assert alu_op = "0001" and branch = '1' and alu_src = '0'
        report "BEQ failed" severity error;

        -- JAL (J-type)
        instr <= x"000000EF"; wait for clk_period;
        assert jump = '1' and reg_write = '1'
        report "JAL failed" severity error;

        -- LUI (U-type)
        instr <= x"000002B7"; wait for clk_period;
        assert alu_op = "0010" and reg_write = '1'
        report "LUI failed" severity error;

        report "All decoder tests passed." severity note;
        wait;
    end process;
end sim;
