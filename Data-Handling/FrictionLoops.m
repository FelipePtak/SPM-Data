clear
clc
close all

%% Estabelecendo diretorio

home = 'F:\Documentos\Felipe\PUC\DOUTORADO\TMD\MoS2\Star1\B\Setpoint\';
output_dir = 'F:\Documentos\Felipe\PUC\DOUTORADO\TMD\MoS2\Star1\B\Setpoint\Loops\';
mkdir(output_dir);
file = dir([home, 'STAR_B.*']);

NumOfFiles = length(file);

ImageList(NumOfFiles) = struct('Name', [], 'Trace', [], 'Retrace', []);

%% Pegando arquivos
% Válido apenas para arquivos com canais traço e retraço

Map{NumOfFiles} = 0;

img{NumOfFiles} = zeros;
ch{NumOfFiles} = zeros;
trace{NumOfFiles} = zeros;
retrace{NumOfFiles} = zeros;
name{NumOfFiles} = zeros;
ext{NumOfFiles} = zeros;

for i=1:NumOfFiles
    
    open_str = strcat(home, file(i).name);
    [img{i}, ch{i}] = openNano(open_str);
    
    [filepath, name{i}, ext{i}] = fileparts(open_str);
    
    %defl = img{i}(:,:,1); % deflexão
    trace{i} = img{i}(:,:,1); % Traço em V
    retrace{i} = img{i}(:,:,2); % Retraço em V
    
    ImageList(i).Name = open_str;
    ImageList(i).Trace = trace{i};
    ImageList(i).Retrace = retrace{i};
    
end
%% Conversao de Volts para Newtons

kn = 0.125; % N/m - constante de mola do cantilever
kt = 82.2; % N/m - constante torsional de mola do cantilever
S1 = 0.00000008098; % m/V - inverso da sensibilidade
Cn = 1.41e-5; % N/rad

conv = sens_conversion(kn,kt,Cn,S1);

%% Figuras com os loops

xspace = linspace(0,5,256);

ImgNewt = struct('Name', [], 'Trace', [], 'Retrace', []);

Trace{NumOfFiles} = zeros;
Retrace{NumOfFiles} = zeros;

for j=1:NumOfFiles
    
    ImgNewt(j).Name = ImageList(j).Name;
    
    ImgNewt(j).Trace = conv*ImageList(j).Trace;
    Trace{j} = ImgNewt(j).Trace;
    ImgNewt(j).Retrace = conv*ImageList(j).Retrace;
    Retrace{j} = ImgNewt(j).Retrace;
    
    folderstr1 = strcat(name{j}, ext{j});
    folderstr2 = strrep(folderstr1, '.', '-');
    foldstr = strcat(output_dir, folderstr2, '\');
    mkdir(foldstr);
    
    for k=1:256
        
        figure(), plot(xspace, ImgNewt(j).Trace(k,:), 'b-', 'LineWidth', 2)
        hold on
        plot(xspace, ImgNewt(j).Retrace(k,:), 'r--', 'LineWidth', 2)
        xlabel('Displacement (nm)', 'FontSize', 16)
        ylabel('Lateral force (nN)', 'FontSize', 16)
        hold off
        
        figstr1 = strcat(foldstr, 'Line-', num2str(k), '.png');
        figstr2 = strcat(foldstr, 'Line-', num2str(k), '.pdf');
        
        saveas(gcf, figstr1);
        saveas(gcf, figstr2);
        
    end
   
    close all;
    
end
