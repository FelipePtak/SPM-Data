% Script p/ criar mapas de força de fricção
% Consiste em importar duas matrizes .txt
% uma é img de ida, e outra a img de volta
% calcular Ff = (1/2)*(ida - volta);

clear;
clc; close all

%% importando os arquivos

[files, path] = uigetfile('*.txt', 'Multiselect', 'on');

NumOfFiles = length(files);

%% Calcular mapa
% FricFiles.Name válido p/ arqs. c/ nome 'MF-18-MultiLayer-date-time-'

FricFile = struct('Name', [], 'Fwd', [],...
    'Bwd', [], 'Map', []);

openstr{NumOfFiles} = zeros;

FricFile.Name = strcat(files{1}(1:36), '.jpk');

for i=1:NumOfFiles
    
      openstr{i} = strcat(path, files{i});
    
end

% Por ordem alfabetica, openstr{1} = bwd; openstr{2} = fwd;
FricFile.Fwd = dlmread(openstr{2});
FricFile.Bwd = dlmread(openstr{1});
FricFile.Map = (1/2)*(FricFile.Fwd - FricFile.Bwd);

%% Salva a matriz do mapa em .txt

outdir = strcat(path, 'Maps\');
outstr = strcat(outdir, files{1}(1:36), '-Aligned-Map.txt');

dlmwrite(outstr, FricFile.Map,'delimiter', '\t');