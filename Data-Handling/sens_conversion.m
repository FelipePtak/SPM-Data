function sens = sens_conversion(kn, kt, Cn, S1)

h = 3.3e-6; % m
t = 0.62e-6; % m
eta = 2.4; % admensional
S_in = 1; % V/V
S = 1/S1; % m/V

C_l = kt*(h + t/2)*S_in*kn/(S*eta*Cn); % N/V
sens = C_l*1000000000; % nN/V

end
