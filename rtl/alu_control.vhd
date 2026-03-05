library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ALU Control for RV32I.
-- Generates a compact ALU operation code based on opcode/funct3/funct7 and a coarse alu_op_ctrl.
--
-- NOTE: For LOAD/STORE and AUIPC the ALU must perform ADD regardless of funct3.
entity alu_control is
    Port (
        opcode             : in  std_logic_vector(6 downto 0);
        alu_op_ctrl        : in  std_logic_vector(1 downto 0);
        funct3             : in  std_logic_vector(2 downto 0);
        funct7             : in  std_logic_vector(6 downto 0);
        alu_control_signal : out std_logic_vector(3 downto 0)
    );
end alu_control;

architecture rtl of alu_control is
begin
    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(opcode, alu_op_ctrl, funct3, funct7)
    begin
        -- Default to ADD (safe) and let trap/illegal logic handle invalid encodings.
        alu_control_signal <= "0000";

        -- Force ADD for address/PC calculations
        if opcode = "0000011" or opcode = "0100011" or opcode = "0010111" then
            alu_control_signal <= "0000"; -- ADD
        elsif opcode = "0110111" then
            alu_control_signal <= "0010"; -- LUI: pass B
        else
            case alu_op_ctrl is
                when "10" => -- R-type
                    case funct3 is
                        when "000" =>
                            if funct7 = "0000000" then alu_control_signal <= "0000"; -- ADD
                            elsif funct7 = "0100000" then alu_control_signal <= "0001"; -- SUB
                            else alu_control_signal <= "1111";
                            end if;
                        when "001" =>
                            if funct7 = "0000000" then alu_control_signal <= "0011"; -- SLL
                            else alu_control_signal <= "1111";
                            end if;
                        when "010" =>
                            if funct7 = "0000000" then alu_control_signal <= "0100"; -- SLT
                            else alu_control_signal <= "1111";
                            end if;
                        when "011" =>
                            if funct7 = "0000000" then alu_control_signal <= "0101"; -- SLTU
                            else alu_control_signal <= "1111";
                            end if;
                        when "100" =>
                            if funct7 = "0000000" then alu_control_signal <= "0110"; -- XOR
                            else alu_control_signal <= "1111";
                            end if;
                        when "101" =>
                            if funct7 = "0000000" then alu_control_signal <= "0111"; -- SRL
                            elsif funct7 = "0100000" then alu_control_signal <= "1000"; -- SRA
                            else alu_control_signal <= "1111";
                            end if;
                        when "110" =>
                            if funct7 = "0000000" then alu_control_signal <= "1001"; -- OR
                            else alu_control_signal <= "1111";
                            end if;
                        when "111" =>
                            if funct7 = "0000000" then alu_control_signal <= "1010"; -- AND
                            else alu_control_signal <= "1111";
                            end if;
                        when others =>
                            alu_control_signal <= "1111";
                    end case;

                when "00" => -- I-type
                    case funct3 is
                        when "000" => alu_control_signal <= "0000"; -- ADDI
                        when "010" => alu_control_signal <= "0100"; -- SLTI
                        when "011" => alu_control_signal <= "0101"; -- SLTIU
                        when "100" => alu_control_signal <= "0110"; -- XORI
                        when "110" => alu_control_signal <= "1001"; -- ORI
                        when "111" => alu_control_signal <= "1010"; -- ANDI
                        when "001" =>
                            if funct7 = "0000000" then alu_control_signal <= "0011"; -- SLLI
                            else alu_control_signal <= "1111";
                            end if;
                        when "101" =>
                            if funct7 = "0000000" then alu_control_signal <= "0111"; -- SRLI
                            elsif funct7 = "0100000" then alu_control_signal <= "1000"; -- SRAI
                            else alu_control_signal <= "1111";
                            end if;
                        when others =>
                            alu_control_signal <= "1111";
                    end case;

                when others =>
                    -- Branches handled by dedicated comparator; ALU op not relevant.
                    alu_control_signal <= "0000";
            end case;
        end if;
    end process;
end rtl;
