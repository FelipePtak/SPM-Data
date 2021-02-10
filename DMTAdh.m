function y = DMTAdh(eta, x)

Fad = eta(2);
y = eta(1)*(Fad + x).^(2/3);

end