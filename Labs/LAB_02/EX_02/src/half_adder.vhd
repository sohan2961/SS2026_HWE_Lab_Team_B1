entity half_adder is
    Port (
        A     : in  bit;
        B     : in  bit;
        SUM   : out bit;
        CARRY : out bit
    );
end entity;

architecture Behavioral of half_adder is
begin
    SUM   <= A xor B;
    CARRY <= A and B;
end Behavioral;
