library STANDARD;
use STANDARD.all;

entity Two_Digit_Counter is
    port (
        CLK        : in  bit;
        START_STOP : in  bit;
        CLEAR      : in  bit;

        CA : out bit;
        CB : out bit;
        CC : out bit;
        CD : out bit;
        CE : out bit;
        CF : out bit;
        CG : out bit;
        DP : out bit;

        AN : out bit_vector(7 downto 0)
    );
end entity Two_Digit_Counter;

architecture rtl of Two_Digit_Counter is

    component clk_divider is
        generic (
            N : positive := 100_000_000
        );
        port (
            CLK   : in  bit;
            CLK_N : out bit
        );
    end component;

    subtype seven_segment_t is bit_vector(6 downto 0);

    function decode_digit(digit : integer) return seven_segment_t is
    begin
        case digit is
            when 0      => return "0000001";
            when 1      => return "1001111";
            when 2      => return "0010010";
            when 3      => return "0000110";
            when 4      => return "1001100";
            when 5      => return "0100100";
            when 6      => return "0100000";
            when 7      => return "0001111";
            when 8      => return "0000000";
            when 9      => return "0000100";
            when others => return "1111111";
        end case;
    end function;

    signal count_clk    : bit;
    signal scan_clk     : bit;
    signal digit_select : bit := '0';

    signal units : integer range 0 to 9 := 0;
    signal tens  : integer range 0 to 9 := 0;

    signal segments : seven_segment_t;

begin

    COUNT_CLOCK_DIVIDER : clk_divider
        generic map (
            N => 100_000_000
        )
        port map (
            CLK   => CLK,
            CLK_N => count_clk
        );

    DISPLAY_CLOCK_DIVIDER : clk_divider
        generic map (
            N => 100_000
        )
        port map (
            CLK   => CLK,
            CLK_N => scan_clk
        );

    counting_process : process (count_clk, CLEAR)
    begin
        if CLEAR = '1' then
            units <= 0;
            tens  <= 0;
        elsif count_clk'event and count_clk = '1' then
            if START_STOP = '1' then
                if units = 9 then
                    units <= 0;

                    if tens = 9 then
                        tens <= 0;
                    else
                        tens <= tens + 1;
                    end if;
                else
                    units <= units + 1;
                end if;
            end if;
        end if;
    end process;

    multiplex_process : process (scan_clk, CLEAR)
    begin
        if CLEAR = '1' then
            digit_select <= '0';
        elsif scan_clk'event and scan_clk = '1' then
            digit_select <= not digit_select;
        end if;
    end process;

    display_process : process (digit_select, units, tens)
    begin
        if digit_select = '0' then
            segments <= decode_digit(units);
            AN <= "11111110";
        else
            segments <= decode_digit(tens);
            AN <= "11111101";
        end if;
    end process;

    CA <= segments(6);
    CB <= segments(5);
    CC <= segments(4);
    CD <= segments(3);
    CE <= segments(2);
    CF <= segments(1);
    CG <= segments(0);

    DP <= '1';

end architecture rtl;
