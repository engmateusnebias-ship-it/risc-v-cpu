library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_trap_unit is
end tb_trap_unit;

architecture tb of tb_trap_unit is
    signal pc : std_logic_vector(31 downto 0) := x"00000000";
    signal illegal_insn, ecall, ebreak, misaligned_ls, misaligned_fetch : std_logic := '0';
    signal trap_taken : std_logic;
    signal trap_target : std_logic_vector(31 downto 0);
    signal trap_cause : std_logic_vector(3 downto 0);

    procedure check(cond : boolean; msg : string) is
    begin
        assert cond report msg severity failure;
    end procedure;
begin
    dut: entity work.trap_unit
        generic map (
            TRAP_VECTOR => x"00000080"
        )
        port map (
            pc               => pc,
            illegal_insn     => illegal_insn,
            ecall            => ecall,
            ebreak           => ebreak,
            misaligned_ls    => misaligned_ls,
            misaligned_fetch => misaligned_fetch,
            trap_taken       => trap_taken,
            trap_target      => trap_target,
            trap_cause       => trap_cause
        );

    process
    begin
        -- illegal instruction
        illegal_insn <= '1';
        wait for 1 ns;
        check(trap_taken='1' and trap_target=x"00000080", "Illegal trap failed");
        illegal_insn <= '0';

        -- misaligned fetch has priority
        misaligned_fetch <= '1';
        illegal_insn <= '1';
        wait for 1 ns;
        check(trap_cause="0001", "Priority trap failed");
        misaligned_fetch <= '0'; illegal_insn <= '0';

        -- ecall
        ecall <= '1';
        wait for 1 ns;
        check(trap_taken='1' and trap_cause="0100", "ECALL trap failed");
        ecall <= '0';

        report "tb_trap_unit PASSED" severity note;
        wait;
    end process;
end tb;
