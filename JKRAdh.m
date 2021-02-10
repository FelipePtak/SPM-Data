function y = JKRAdh(B, x)

Fad = B(2);

y = B(1)*(sqrt(Fad) + sqrt(Fad + x)).^(4/3);

end