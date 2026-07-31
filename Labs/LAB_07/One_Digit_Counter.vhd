library STANDARD;
use STANDARD.all;

entity One_Digit_Counter is
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
end entity One_Digit_Counter;

architecture rtl of One_Digit_Counter is

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

    signal slow_clk    : bit;
    signal count_value : integer range 0 to 9 := 0;
    signal segments    : seven_segment_t;

begin

    CLOCK_DIVIDER_INSTANCE : clk_divider
        generic map (
            N => 100_000_000
        )
        port map (
            CLK   => CLK,
            CLK_N => slow_clk
        );

    counting_process : process (slow_clk, CLEAR)
    begin
        if CLEAR = '1' then
            count_value <= 0;
        elsif slow_clk'event and slow_clk = '1' then
            if START_STOP = '1' then
                if count_value = 9 then
                    count_value <= 0;
                else
                    count_value <= count_value + 1;
                end if;
            end if;
        end if;
    end process;

    segments <= decode_digit(count_value);

    CA <= segments(6);
    CB <= segments(5);
    CC <= segments(4);
    CD <= segments(3);
    CE <= segments(2);
    CF <= segments(1);
    CG <= segments(0);

    DP <= '1';
    AN <= "11111110";

end architecture rtl;
