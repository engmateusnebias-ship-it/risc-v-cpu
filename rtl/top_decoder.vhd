library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_decoder is
    Port (
        dummy_clk  : in std_logic;  -- clock fictício para análise de timing
        opcode     : in  std_logic_vector(6 downto 0);
        funct3     : in  std_logic_vector(2 downto 0);
        funct7     : in  std_logic_vector(6 downto 0);
        alu_op     : out std_logic_vector(3 downto 0);
        reg_write  : out std_logic;
        mem_read   : out std_logic;
        mem_write  : out std_logic;
        mem_to_reg : out std_logic;
        alu_src    : out std_logic;
        branch     : out std_logic;
        jump       : out std_logic
    );
end top_decoder;


architecture Behavioral of top_decoder is
    component decoder
        Port (
            opcode     : in  std_logic_vector(6 downto 0);
            funct3     : in  std_logic_vector(2 downto 0);
            funct7     : in  std_logic_vector(6 downto 0);
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
    UUT: decoder
        port map (
            opcode     => opcode,
            funct3     => funct3,
            funct7     => funct7,
            alu_op     => alu_op,
            reg_write  => reg_write,
            mem_read   => mem_read,
            mem_write  => mem_write,
            mem_to_reg => mem_to_reg,
            alu_src    => alu_src,
            branch     => branch,
            jump       => jump
        );
end Behavioral;
