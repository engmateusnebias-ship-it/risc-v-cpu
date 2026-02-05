library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_decoder is
end tb_decoder;

architecture sim of tb_decoder is
    signal opcode     : std_logic_vector(6 downto 0);
    signal funct3     : std_logic_vector(2 downto 0);
    signal funct7     : std_logic_vector(6 downto 0);
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
    uut: decoder
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

    stimulus: process
    begin
        -- Teste: AND
        opcode <= "0110011"; funct3 <= "111"; funct7 <= "0000000"; wait for 10 ns;
        -- Teste: ORI
        opcode <= "0010011"; funct3 <= "110"; funct7 <= "0000000"; wait for 10 ns;
        -- Teste: SLL
        opcode <= "0110011"; funct3 <= "001"; funct7 <= "0000000"; wait for 10 ns;
        -- Teste: SRLI
        opcode <= "0010011"; funct3 <= "101"; funct7 <= "0000000"; wait for 10 ns;
        -- Teste: SRA
        opcode <= "0110011"; funct3 <= "101"; funct7 <= "0100000"; wait for 10 ns;
        wait;
    end process;
end sim;
