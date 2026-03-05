library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Simple memory-mapped timer.
-- Registers (byte addresses):
--  - 0x0000_0020 TIMER_COUNT (RO): increments every clock when enabled
--  - 0x0000_0024 TIMER_CMP   (RW): compare value
--  - 0x0000_0028 TIMER_CTRL  (RW): bit0=enable, bit1=irq_enable, bit2=clear (self-clearing)
-- IRQ behavior (optional): irq asserted when (enable and irq_enable and count == cmp)
entity timer is
    Port (
        clk       : in  std_logic;
        rst       : in  std_logic;

        we        : in  std_logic;
        re        : in  std_logic;
        addr      : in  std_logic_vector(31 downto 0);
        wdata     : in  std_logic_vector(31 downto 0);
        wstrb     : in  std_logic_vector(3 downto 0);
        rdata     : out std_logic_vector(31 downto 0);

        irq       : out std_logic
    );
end timer;

architecture rtl of timer is
    signal count_reg : unsigned(31 downto 0) := (others => '0');
    signal cmp_reg   : unsigned(31 downto 0) := (others => '0');
    signal enable    : std_logic := '0';
    signal irq_en    : std_logic := '0';
begin

    process(clk, rst)
        variable new_cmp : unsigned(31 downto 0);
        variable new_ctrl : std_logic_vector(31 downto 0);
    begin
        if rst = '1' then
            count_reg <= (others => '0');
            cmp_reg   <= (others => '0');
            enable    <= '0';
            irq_en    <= '0';
        elsif rising_edge(clk) then
            -- Timer tick
            if enable = '1' then
                count_reg <= count_reg + 1;
            end if;

            -- Writes
            if we = '1' then
                if addr = x"00000024" then
                    -- TIMER_CMP: full word write only (ignore partial for simplicity)
                    if wstrb = "1111" then
                        cmp_reg <= unsigned(wdata);
                    end if;
                elsif addr = x"00000028" then
                    -- TIMER_CTRL: bit0 enable, bit1 irq_enable, bit2 clear
                    new_ctrl := wdata;
                    if wstrb(0) = '1' then
                        enable <= new_ctrl(0);
                        irq_en <= new_ctrl(1);
                        if new_ctrl(2) = '1' then
                            count_reg <= (others => '0');
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Read
    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(re, addr, count_reg, cmp_reg, enable, irq_en)
        variable ctrl : std_logic_vector(31 downto 0);
    begin
        rdata <= (others => '0');
        ctrl := (others => '0');
        ctrl(0) := enable;
        ctrl(1) := irq_en;

        if re = '1' then
            if addr = x"00000020" then
                rdata <= std_logic_vector(count_reg);
            elsif addr = x"00000024" then
                rdata <= std_logic_vector(cmp_reg);
            elsif addr = x"00000028" then
                rdata <= ctrl;
            else
                rdata <= (others => '0');
            end if;
        end if;
    end process;

    irq <= '1' when (enable = '1' and irq_en = '1' and count_reg = cmp_reg) else '0';
end rtl;
