entity half_subtractor is
    port (
        A      : in  bit;
        B      : in  bit;
        DIFF   : out bit;
        BORROW : out bit
    );
end entity;

architecture Behavioral of half_subtractor is
begin

    DIFF   <= A xor B;
    BORROW <= (not A) and B;

end Behavioral;
