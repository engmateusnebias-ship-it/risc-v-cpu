library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder is
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
end decoder;

architecture Behavioral of decoder is
begin
    process(opcode, funct3, funct7)
    begin
        alu_op     <= "0000";
        reg_write  <= '0';
        mem_read   <= '0';
        mem_write  <= '0';
        mem_to_reg <= '0';
        alu_src    <= '0';
        branch     <= '0';
        jump       <= '0';

        case opcode is
            when "0110011" =>  -- R-type
                reg_write <= '1';
                alu_src   <= '0';
                case funct3 is
                    when "000" =>
                        if funct7 = "0000000" then alu_op <= "0000"; -- ADD
                        elsif funct7 = "0100000" then alu_op <= "0001"; -- SUB
                        else alu_op <= "1111";
                        end if;
                    when "111" => alu_op <= "1010"; -- AND
                    when "110" => alu_op <= "1001"; -- OR
                    when "100" => alu_op <= "0110"; -- XOR
                    when "010" => alu_op <= "0100"; -- SLT
                    when "011" => alu_op <= "0101"; -- SLTU
                    when "001" => alu_op <= "0011"; -- SLL
                    when "101" =>
                        if funct7 = "0000000" then alu_op <= "0111"; -- SRL
                        elsif funct7 = "0100000" then alu_op <= "1000"; -- SRA
                        else alu_op <= "1111";
                        end if;
                    when others => alu_op <= "1111";
                end case;

            when "0010011" =>  -- I-type
                reg_write <= '1';
                alu_src   <= '1';
                case funct3 is
                    when "000" => alu_op <= "0000"; -- ADDI
                    when "111" => alu_op <= "1010"; -- ANDI
                    when "110" => alu_op <= "1001"; -- ORI
                    when "100" => alu_op <= "0110"; -- XORI
                    when "010" => alu_op <= "0100"; -- SLTI
                    when "011" => alu_op <= "0101"; -- SLTIU
                    when "001" => alu_op <= "0011"; -- SLLI
                    when "101" =>
                        if funct7 = "0000000" then alu_op <= "0111"; -- SRLI
                        elsif funct7 = "0100000" then alu_op <= "1000"; -- SRAI
                        else alu_op <= "1111";
                        end if;
                    when others => alu_op <= "1111";
                end case;

            when "0000011" =>  -- LW
                reg_write  <= '1';
                mem_read   <= '1';
                mem_to_reg <= '1';
                alu_src    <= '1';
                alu_op     <= "0000"; -- ADD

            when "0100011" =>  -- SW
                mem_write  <= '1';
                alu_src    <= '1';
                alu_op     <= "0000"; -- ADD

            when "1100011" =>  -- BEQ
                branch     <= '1';
                alu_src    <= '0';
                case funct3 is
                    when "000" => alu_op <= "0001"; -- SUB for BEQ
                    when others => alu_op <= "1111";
                end case;

            when "1101111" =>  -- JAL
                reg_write  <= '1';
                jump       <= '1';

            when "0110111" =>  -- LUI
                reg_write  <= '1';
                alu_op     <= "0010"; -- LUI

            when others =>
                alu_op <= "1111";
        end case;
    end process;
end Behavioral;
