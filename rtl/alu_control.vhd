library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_control is
    Port (
        alu_op_ctrl        : in  std_logic_vector(1 downto 0);
        funct3             : in  std_logic_vector(2 downto 0);
        funct7             : in  std_logic_vector(6 downto 0);
        alu_control_signal : out std_logic_vector(3 downto 0)
    );
end alu_control;

architecture Behavioral of alu_control is
begin
    process(alu_op_ctrl, funct3, funct7)
    begin
        case alu_op_ctrl is
            when "10" => -- R-type
                case funct3 is
                    when "000" =>
                        if funct7 = "0000000" then alu_control_signal <= "0000"; -- ADD
                        elsif funct7 = "0100000" then alu_control_signal <= "0001"; -- SUB
                        else alu_control_signal <= "1111";
                        end if;
                    when "111" => alu_control_signal <= "1010"; -- AND
                    when "110" => alu_control_signal <= "1001"; -- OR
                    when "100" => alu_control_signal <= "0110"; -- XOR
                    when "010" => alu_control_signal <= "0100"; -- SLT
                    when "011" => alu_control_signal <= "0101"; -- SLTU
                    when "001" => alu_control_signal <= "0011"; -- SLL
                    when "101" =>
                        if funct7 = "0000000" then alu_control_signal <= "0111"; -- SRL
                        elsif funct7 = "0100000" then alu_control_signal <= "1000"; -- SRA
                        else alu_control_signal <= "1111";
                        end if;
                    when others => alu_control_signal <= "1111";
                end case;

            when "00" => -- I-type, LW, SW
                case funct3 is
                    when "000" => alu_control_signal <= "0000"; -- ADDI
                    when "111" => alu_control_signal <= "1010"; -- ANDI
                    when "110" => alu_control_signal <= "1001"; -- ORI
                    when "100" => alu_control_signal <= "0110"; -- XORI
                    when "010" => alu_control_signal <= "0100"; -- SLTI
                    when "011" => alu_control_signal <= "0101"; -- SLTIU
                    when "001" => alu_control_signal <= "0011"; -- SLLI
                    when "101" =>
                        if funct7 = "0000000" then alu_control_signal <= "0111"; -- SRLI
                        elsif funct7 = "0100000" then alu_control_signal <= "1000"; -- SRAI
                        else alu_control_signal <= "1111";
                        end if;
                    when others => alu_control_signal <= "1111";
                end case;

            when "01" => -- Branch
                alu_control_signal <= "0001"; -- SUB for comparison

            when "11" => -- LUI
                alu_control_signal <= "0010"; -- Pass immediate

            when others =>
                alu_control_signal <= "1111";
        end case;
    end process;
end Behavioral;
