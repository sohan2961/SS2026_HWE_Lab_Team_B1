entity XORGatter is 
 port (X,Y: in bit; 
       Z:out bit) ; 
end entity; 
architecture Data of XORGatter is 
begin Z <= X xor Y; 
end architecture;
