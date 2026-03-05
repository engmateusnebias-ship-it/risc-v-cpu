library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Load/Store Unit (LSU) for RV32I.
-- Handles:
--  - Byte-enable generation for SB/SH/SW
--  - Store data alignment
--  - Load data extraction and sign/zero extension for LB/LH/LW/LBU/LHU
--  - Misalignment detection
entity load_store_unit is
    Port (
        addr           : in  std_logic_vector(31 downto 0);
        funct3         : in  std_logic_vector(2 downto 0);
        is_load        : in  std_logic;
        is_store       : in  std_logic;

        rs2_store_data : in  std_logic_vector(31 downto 0); -- raw store operand
        mem_rdata_raw  : in  std_logic_vector(31 downto 0); -- word read from memory/peripheral

        mem_wdata      : out std_logic_vector(31 downto 0); -- aligned store data
        mem_wstrb      : out std_logic_vector(3 downto 0);  -- byte enables
        load_result    : out std_logic_vector(31 downto 0); -- final load value
        misaligned     : out std_logic
    );
end load_store_unit;

architecture rtl of load_store_unit is
    signal a_low : std_logic_vector(1 downto 0);
begin
    a_low <= addr(1 downto 0);

    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(addr, a_low, funct3, is_load, is_store, rs2_store_data, mem_rdata_raw)
        variable wstrb_v : std_logic_vector(3 downto 0);
        variable wdata_v : std_logic_vector(31 downto 0);
        variable mis_v   : std_logic;

        variable b       : std_logic_vector(7 downto 0);
        variable h       : std_logic_vector(15 downto 0);
        variable word_v  : std_logic_vector(31 downto 0);
    begin
        wstrb_v := (others => '0');
        wdata_v := (others => '0');
        mis_v   := '0';

        -- Default load result: raw word (LW)
        word_v := mem_rdata_raw;

        -- Store path
        if is_store = '1' then
            case funct3 is
                when "000" => -- SB
                    case a_low is
                        when "00" => wstrb_v := "0001"; wdata_v(7 downto 0)   := rs2_store_data(7 downto 0);
                        when "01" => wstrb_v := "0010"; wdata_v(15 downto 8)  := rs2_store_data(7 downto 0);
                        when "10" => wstrb_v := "0100"; wdata_v(23 downto 16) := rs2_store_data(7 downto 0);
                        when others => wstrb_v := "1000"; wdata_v(31 downto 24) := rs2_store_data(7 downto 0);
                    end case;

                when "001" => -- SH
                    if a_low(0) /= '0' then
                        mis_v := '1';
                    end if;
                    if a_low(1) = '0' then
                        wstrb_v := "0011";
                        wdata_v(15 downto 0) := rs2_store_data(15 downto 0);
                    else
                        wstrb_v := "1100";
                        wdata_v(31 downto 16) := rs2_store_data(15 downto 0);
                    end if;

                when "010" => -- SW
                    if a_low /= "00" then
                        mis_v := '1';
                    end if;
                    wstrb_v := "1111";
                    wdata_v := rs2_store_data;

                when others =>
                    -- Invalid store size -> treat as misaligned/illegal at control level
                    wstrb_v := (others => '0');
            end case;
        end if;

        -- Load path
        if is_load = '1' then
            case funct3 is
                when "000" | "100" => -- LB/LBU
                    case a_low is
                        when "00" => b := word_v(7 downto 0);
                        when "01" => b := word_v(15 downto 8);
                        when "10" => b := word_v(23 downto 16);
                        when others => b := word_v(31 downto 24);
                    end case;

                    if funct3 = "000" then
                        -- LB: sign-extend
                        load_result <= std_logic_vector(resize(signed(b), 32));
                    else
                        -- LBU: zero-extend
                        load_result <= (31 downto 8 => '0') & b;
                    end if;

                when "001" | "101" => -- LH/LHU
                    if a_low(0) /= '0' then
                        mis_v := '1';
                    end if;

                    if a_low(1) = '0' then
                        h := word_v(15 downto 0);
                    else
                        h := word_v(31 downto 16);
                    end if;

                    if funct3 = "001" then
                        -- LH: sign-extend
                        load_result <= std_logic_vector(resize(signed(h), 32));
                    else
                        -- LHU: zero-extend
                        load_result <= (31 downto 16 => '0') & h;
                    end if;

                when "010" => -- LW
                    if a_low /= "00" then
                        mis_v := '1';
                    end if;
                    load_result <= word_v;

                when others =>
                    load_result <= (others => '0');
            end case;
        else
            load_result <= (others => '0');
        end if;

        mem_wstrb <= wstrb_v;
        mem_wdata <= wdata_v;
        misaligned <= mis_v;
    end process;
end rtl;
