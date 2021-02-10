function [Fk, Fad, load] = LoadForce(k, S, D, Setzero, Setpoint)

% Funcao para calcular carga total aplicada durante a medida
%
%       [Fk, Fad, load] = LoadForce(k, S, D, Setzero, Setpoint)
%       Fk -> carga aplicada pelo cantilever
%       Fad -> forca de adesao
%       load -> carga total; load = Fk + Fad
%       Parametros dados nas seguiintes unidades:
%       k -> N/m
%       S -> V/nm
%       D -> nm
%       Setzero -> V
%       Setpoint -> V



Fk = (k/S)*(Setpoint - Setzero); % nN

Fad = k*D; % nN

load = (k/S)*(Setpoint - Setzero) + Fad; % nN