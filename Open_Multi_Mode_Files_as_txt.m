clear
clc
close all

%% Estabelecendo diretorio

home = 'F:\Documentos\Felipe\PUC\DOUTORADO\Mica\MF-21\Nanoscope\Load\30 nm\Data\';
output_dir = 'F:\Documentos\Felipe\PUC\DOUTORADO\Mica\MF-21\Nanoscope\Load\30 nm\Text\';
file = dir([home, 'MF21.*']);

NumOfFiles = length(file);

ImageList(NumOfFiles) = struct('Name', [], 'Map', []);

%% Pegando arquivos
% Válido apenas para arquivos com canais traço e retraço

Map{NumOfFiles} = 0;
trace = 0;
retrace = 0; 

img{NumOfFiles} = zeros; ch{NumOfFiles} = zeros;
media(NumOfFiles) = zeros;
desvio(NumOfFiles) = zeros;

for i=1:NumOfFiles
    
    open_str = strcat(home, file(i).name);
    [img{i}, ch{i}] = openNano(open_str);
    
    %defl = img{i}(:,:,1); % deflexão
    trace = img{i}(:,:,1); % Traço em V
    retrace = img{i}(:,:,2); % Retraço em V
    
    Map{i} = (trace - retrace)/2; % Mapa em V
    media(i) = mean(Map{i}(:));
    desvio(i) = std(Map{i}(:));
    
    outstr = strcat(output_dir, file(i).name, '.txt');
    ImageList(i).Name = outstr;
    ImageList(i).Map = Map{i};
    
    dlmwrite(ImageList(i).Name, ImageList(i).Map);
    
end

%% Converte o resultado de Volts para Newtons

kn = 0.279; % N/m - constante de mola do cantilever
kt = 76.7; % N/m - constante torsional de mola do cantilever
S1 = 0.00000004147; % m/V - inverso da sensibilidade
Cn = 1.92e-5; % N/rad

conv = sens_conversion(kn,kt,Cn,S1);

MapNewt = struct('Name', [], 'Map', []);
var = [];

FL{NumOfFiles} = zeros;
med(NumOfFiles) = zeros;
sig(NumOfFiles) = zeros;

for j=1:NumOfFiles
    
    FL{j} = conv*Map{j};
    med(j) = conv*media(j);
    sig(j) = conv*desvio(j);
    
    outstr2 = strcat(output_dir, file(j).name, '-Friction-Map-Newtons.txt');
    MapNewt(j).Name = outstr2;
    MapNewt(j).Map = FL{j};
    
    dlmwrite(MapNewt(j).Name, MapNewt(j).Map);
    
    outstr3 = strcat(output_dir, file(j).name, '-Mean-std.txt');
    var = [med(j) sig(j)];
    
    dlmwrite(outstr3, var)
    
end

%% Deflexão

%{
DeflList = struc('Name', [], 'Defl', [], 'DMed', [ ], 'DSigma', []);

for m = 1:NumOfFiles
   
    outstr6 = strcat(output_dir, file(m).name, '-Deflection.txt');
    DeflList(m).Name = outstr6;
    DeflList(m).Defl = kn*S1*img{m}(:,:,1);
    
    defl_vec = DeflList(m).Defl(:);
    xi = min(defl_vec);
    xf = max(defl_vec);
    defl_n_elms = round(length(defl_vec)^0.5); % numero de bins do hist
    
    [defl_n, defl_centers] = hist(defl_vec, defl_n_elms);
    defl_n_col = defl_n';
    defl_cent_col = defl_centers';
    %out{j} = [cent_col n_col];
    %out{j} = [mu1 sigma1 mu2 sigma2];
    
    
    figure(), bar(defl_centers, defl_n);
    
    DeflList(m).DMed = mean(DeflList(m).Defl(:));
    DeflList(m).DSigma = std(DeflList(m).Defl(:));
    
end
%}

%% Calculo e plot do setpoint

%
%Setpoint = 0.0:0.5:6.0;
Set1 = [0 1.0];
Set2 = 1.0:0.5:8.0;
Setpoint = cat(2, Set1, Set2);
Setzero = -1.842; % V
D = 108.75; % nm
S = 0.024113608; % V/nm

[Fk, Fad, load] = LoadForce(kn, S, D, Setzero, Setpoint);
%

%% Scanning speed
%{

Scan_size = 5; % nm
Scan_rate = [61 40.7 30.5 24.4 24.4 20. 20.3 15.3 15.3 10.2 10.2 7.63 7.63 6.1 6.1 5.1 5.1 4 4 3 2 1]; % Hz
Scan_speed = Scan_size * Scan_rate; % nm/s
Sliding_speed = Scan_speed/1000; % um/s
logv = log(Scan_speed); % ln v
%}

%% Histograma

Ampl(NumOfFiles) = zeros;
mu(NumOfFiles) = zeros;
c(NumOfFiles) = zeros;
sigma(NumOfFiles) = zeros;

for ii=1:NumOfFiles
    
    map_vec = MapNewt(ii).Map(:);
    xi = min(map_vec);
    xf = max(map_vec);
    n_elms = round(length(map_vec)^0.5); % numero de bins do hist
    
    [n, centers] = hist(map_vec, n_elms);
    n_col = n';
    cent_col = centers';
    %out{j} = [cent_col n_col];
    %out{j} = [mu1 sigma1 mu2 sigma2];
    
    
    figure(), bar(centers, n);
    xlim([xi xf])
    hold on
    f = fit(cent_col, n_col, 'gauss1');
    coeff = coeffvalues(f);
    Ampl(ii) = coeff(1); mu(ii) = coeff(2); c(ii) = coeff(3);
    sigma(ii) = c(ii)./sqrt(2);
    
    xspace = linspace(xi,xf);
    yspace = coeff(1)*exp(-((xspace-coeff(2))/coeff(3)).^2);
    
    fig1 = plot(xspace, yspace, 'r', 'LineWidth', 2);
    xlabel('Friction force (nN)', 'FontSize', 16)
    ylabel('Frequency', 'FontSize', 16)
    
end

%% Plot FL x Setpoint

%
figure(), errorbar(Fk, mu, sigma, 'ko', 'MarkerFaceColor', 'k')
xlabel('Applied load (nN)', 'FontSize', 16)
ylabel('Friction force (nN)', 'FontSize', 16)
%

%% Plot FL x v e FL x ln v

%{
figure(), errorbar(Scan_speed, mu, sigma, 'ko', 'MarkerFaceColor', 'k')
xlabel('Scanning speed (nm/s)', 'FontSize', 16)
ylabel('Friction force (nN)', 'FontSize', 16)

figure(), errorbar(logv, mu, sigma, 'ko', 'MarkerFaceColor', 'k');
xlabel('ln v', 'FontSize', 16)
ylabel('Friction force (nN)', 'FontSize', 16)
%}

%% FL x FN

output(NumOfFiles, 3) = zeros;

for k=1:NumOfFiles
    
    %Cria uma variável de saida
    %Matriz dimensao NumOfFiles x 3
    output(k,:) = [Fk(k) mu(k) sigma(k)];
    
end

outstr4 = strcat(output_dir, 'Friction-Applied-Load.txt');
dlmwrite(outstr4, output, 'delimiter', '\t')

%% Salva um arquivo com v med sig
%{

output2(NumOfFiles, 3) = zeros;
output3(NumOfFiles, 3) = zeros;

for k=1:NumOfFiles
    
    % Cria uma variável de saida
    % Matriz dimensao NumOfFiles x 3
    output2(k,:) = [Scan_speed(k) mu(k) sigma(k)];
    output3(k,:) = [logv(k) mu(k) sigma(k)];
    
end

outstr4 = strcat(output_dir, 'Friction-Sliding-Speed.txt');
outstr5 = strcat(output_dir, 'Friction-log-v.txt');
dlmwrite(outstr4, output2, 'delimiter', '\t')
dlmwrite(outstr5, output3, 'delimiter', '\t')
%}