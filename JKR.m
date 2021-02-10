function y = JKR(B, x)

Fad = 15;

y = B*(sqrt(Fad) + sqrt(Fad + x)).^(4/3);

end