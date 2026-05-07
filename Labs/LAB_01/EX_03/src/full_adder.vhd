entity full_adder is
    port (
        A     : in  bit;
        B     : in  bit;
        CIN   : in  bit;
        SUM   : out bit;
        CARRY : out bit
    );
end entity;

architecture Behavioral of full_adder is
begin

    SUM   <= A xor B xor CIN;
    CARRY <= (A and B) or (A and CIN) or (B and CIN);

end Behavioral;