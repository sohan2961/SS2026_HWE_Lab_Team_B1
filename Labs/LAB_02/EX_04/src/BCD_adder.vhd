
-- 4-bit BCD Adder
-- Uses the 4-bit Carry Ripple Adder from Exercise 02: CR_adder



entity BCD_adder is

  Generic (
        N : integer := 4
         );
    
    Port (
        A    : in  BIT_VECTOR(N-1 downto 0);
        B    : in  BIT_VECTOR(N-1 downto 0);
        CARRY_IN  : in  BIT;
        SUM    : out BIT_VECTOR(N-1 downto 0);
        CARRY_OUT : out BIT
    );

end entity;

architecture Structural of BCD_adder is

    component CR_adder is
     Generic (
            N : integer := 4
        );

        port (
            A         : in  bit_vector(N-1 downto 0);
            B         : in  bit_vector(N-1 downto 0);
            CARRY_IN  : in  bit;
            SUM       : out bit_vector(N-1 downto 0);
            CARRY_OUT : out bit
        );
    end component;

    signal CR_adder_1_SUM   : bit_vector(N-1 downto 0);
    signal CR_adder_1_CARRY : bit;
    signal BCD_Condition   : bit;
    signal ADD_6        : bit_vector(N-1 downto 0);
    signal FINAL_CARRY : bit;

begin

    -- First adder: normal 4-bit binary addition
    CR_ADDER_1 : CR_adder
        generic map (
            N => N
        )
        port map (
            A         => A,
            B         => B,
            CARRY_IN  => CARRY_IN,
            SUM       => CR_adder_1_SUM,
            CARRY_OUT => CR_adder_1_CARRY
        );

    -- BCD correction condition:
    -- If result is greater than 9, or binary carry is 1, add 0110.
    BCD_Condition <= CR_adder_1_CARRY or
                  (CR_adder_1_SUM(3) and CR_adder_1_SUM(2)) or
                  (CR_adder_1_SUM(3) and CR_adder_1_SUM(1));

    -- Correction number = 0110 when correction is needed, otherwise 0000
    ADD_6(3) <= '0';
    ADD_6(2) <= BCD_Condition;
    ADD_6(1) <= BCD_Condition;
    ADD_6(0) <= '0';

    -- Second adder: add 0110 if correction is required
    CR_ADDER_2 : CR_adder
       generic map (
            N => N
        )
        port map (
            A         => CR_adder_1_SUM,
            B         => ADD_6,
            CARRY_IN  => '0',
            SUM       => SUM,
            CARRY_OUT => FINAL_CARRY
        );

    -- Decimal carry to next BCD digit
    CARRY_OUT <= BCD_Condition;

end Structural;

