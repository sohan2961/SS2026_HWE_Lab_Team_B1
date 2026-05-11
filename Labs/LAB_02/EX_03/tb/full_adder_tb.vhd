entity full_adder_tb is
end full_adder_tb;

architecture Structural of full_adder_tb is

    component full_adder
        port (
            A    : in  bit;
            B    : in  bit;
            CARRY_IN  : in  bit;
            SUM    : out bit;
            CARRY_OUT : out bit
        );
    end component;

    signal A_tb    : bit := '0';
    signal B_tb    : bit := '0';
    signal CARRY_IN_tb  : bit := '0';
    signal SUM_tb    : bit;
    signal CARRY_OUT_tb : bit;

begin

    DUT : full_adder
         port map (
            A    => A_tb,
            B    => B_tb,
            CARRY_IN  => CARRY_IN_tb,
            SUM    => SUM_tb,
            CARRY_OUT => CARRY_OUT_tb
        );

  -- Stimulus generation
    
    A_tb <= '0',
            '0' after 10 ns,
            '0' after 20 ns,
            '0' after 30 ns,
            '1' after 40 ns,
            '1' after 50 ns,
            '1' after 60 ns,
            '1' after 70 ns;
 
    B_tb <= '0',
            '0' after 10 ns,
            '1' after 20 ns,
            '1' after 30 ns,
            '0' after 40 ns,
            '0' after 50 ns,
            '1' after 60 ns,
            '1' after 70 ns;
 
CARRY_IN_tb <= '0',
              '1' after 10 ns,
              '0' after 20 ns,
              '1' after 30 ns,
              '0' after 40 ns,
              '1' after 50 ns,
              '0' after 60 ns,
              '1' after 70 ns;

end Structural;
