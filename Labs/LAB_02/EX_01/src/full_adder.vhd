entity full_adder is
    Port (
        A     : in  bit;
        B     : in  bit;
        CARRY_IN : in bit;
        SUM   : out bit;
        CARRY_OUT : out bit

    );
end entity;

architecture Structural of full_adder is

    component half_adder is
        Port (
            A : in  bit;
            B : in  bit;
            SUM : out bit;
            CARRY : out bit
        );
    end component;

 -- Internal signals
    signal SUM_1 : bit;
    signal CARRY_1 : bit;
    signal CARRY_2 : bit;


begin
    
    HA1 : half_adder
        port map (
            A => A,
            B => B,
            SUM => SUM_1,
            CARRY => CARRY_1
        );

    HA2 : half_adder
        port map (
            A => SUM_1,
            B => CARRY_in,
            SUM => SUM,
            CARRY => CARRY_2
        );

    CARRY_OUT <= CARRY_1 or CARRY_2;

end Structural;

