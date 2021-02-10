function [Load, Fad, Fk] = LoadJPK(S, Adh, k, Setpoint)

Dist = Adh/S; % um
Adhesion = Dist*k; % uN
Fad = Adhesion*1000; % nN

Cant = (k/S)*Setpoint; % uN
Fk = Cant*1000; % nN

Load = Fad + Fk; % nN -> força normal total
