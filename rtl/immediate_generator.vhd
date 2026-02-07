library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity immediate_generator is
    Port (
        instr     : in  std_logic_vector(31 downto 0);  -- Full 32-bit instruction
        imm_out   : out std_logic_vector(31 downto 0)   -- Sign-extended immediate
    );
end immediate_generator;

architecture rtl of immediate_generator is
    signal opcode : std_logic_vector(6 downto 0);
    signal imm    : std_logic_vector(31 downto 0);
begin

    opcode <= instr(6 downto 0);

    process(instr, opcode)
    begin
        case opcode is

            -- I-type (e.g., ADDI, LW, JALR)
            when "0010011" | "0000011" | "1100111" =>
                imm <= (others => instr(31)); -- sign extension
                imm(11 downto 0) <= instr(31 downto 20);

            -- S-type (e.g., SW)
            when "0100011" =>
                imm <= (others => instr(31));
                imm(11 downto 5) <= instr(31 downto 25);
                imm(4 downto 0)  <= instr(11 downto 7);

            -- B-type (e.g., BEQ, BNE)
            when "1100011" =>
                imm <= (others => instr(31));
                imm(10 downto 5)<= instr(30 downto 25);
                imm(4 downto 1) <= instr(11 downto 8);
                imm(11)         <= instr(7);
                imm(0)          <= '0';

            -- U-type (e.g., LUI, AUIPC)
            when "0110111" | "0010111" =>
                imm(31 downto 12) <= instr(31 downto 12);
                imm(11 downto 0)  <= (others => '0');

            -- J-type (e.g., JAL)
            when "1101111" =>
                imm <= (others => instr(31));
                imm(20)         <= instr(31);
                imm(10 downto 1)<= instr(30 downto 21);
                imm(11)         <= instr(20);
                imm(19 downto 12)<= instr(19 downto 12);
                imm(0)          <= '0';

            -- Default: zero
            when others =>
                imm <= (others => '0');
        end case;
    end process;

    imm_out <= imm;

end rtl;
