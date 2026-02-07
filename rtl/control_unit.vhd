library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port (
        instr        : in  std_logic_vector(31 downto 0);
        reg_write    : out std_logic;
        alu_src      : out std_logic;
        mem_read     : out std_logic;
        mem_write    : out std_logic;
        mem_to_reg   : out std_logic;
        branch       : out std_logic;
        jump         : out std_logic;
        alu_op_ctrl  : out std_logic_vector(1 downto 0)
    );
end control_unit;

architecture Behavioral of control_unit is
    signal opcode : std_logic_vector(6 downto 0);
begin
    opcode <= instr(6 downto 0);

    process(opcode)
    begin
        -- Default values
        reg_write   <= '0';
        alu_src     <= '0';
        mem_read    <= '0';
        mem_write   <= '0';
        mem_to_reg  <= '0';
        branch      <= '0';
        jump        <= '0';
        alu_op_ctrl <= "00";

        case opcode is
            when "0110011" => -- R-type
                reg_write   <= '1';
                alu_src     <= '0';
                alu_op_ctrl <= "10";

            when "0010011" => -- I-type (ADDI, ANDI, etc.)
                reg_write   <= '1';
                alu_src     <= '1';
                alu_op_ctrl <= "00";

            when "0000011" => -- LW
                reg_write   <= '1';
                mem_read    <= '1';
                mem_to_reg  <= '1';
                alu_src     <= '1';
                alu_op_ctrl <= "00";

            when "0100011" => -- SW
                mem_write   <= '1';
                alu_src     <= '1';
                alu_op_ctrl <= "00";

            when "1100011" => -- BEQ
                branch      <= '1';
                alu_src     <= '0';
                alu_op_ctrl <= "01";

            when "1101111" => -- JAL
                reg_write   <= '1';
                jump        <= '1';
                alu_op_ctrl <= "00";  -- PC-relative ADD

            when "0110111" => -- LUI
                reg_write   <= '1';
                alu_op_ctrl <= "11";  -- LUI-specific

            when others =>
                alu_op_ctrl <= "00";
        end case;
    end process;
end Behavioral;
