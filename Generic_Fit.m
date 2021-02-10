%% Fitting a function to graphene data - Friction force and normal load relation

clear, clc, close all;

%% Import data
home = 'F:\Documentos\Felipe\PUC\DOUTORADO\Grafeno\Fresh\1\';
filename = 'Friction-Applied-Load-v4.txt';
file = strcat(home,filename);
data = importdata(file);
load = data(:,1);
F = data(:,2);
err = data(:,3);
%F1 = data(1:8,2); F2 = data(9:21,2);
%load1 = data(1:8, 1); load2 = data(9:21, 1);
%err1 = data(1:8, 3); err2 = data(9:21, 3);

%{

%Localizando apenas os valores positivos de carga aplicada para o ajuste
%Hertz e Amonton

idx = find(load>=0);
load2 = load(load >= 0);
F2 = F(idx);
err2 = err(idx);

%}

%% Data Fitting

% Initial Parameters

options = statset('Display','iter');

Fad = 15;
eta0 = 1;
mu0_Am = 1;

% Fit curves
% Chamar a funcao
% [X, R, J, CovB] = nlinfit(x, y, @modelfunction, 'Weights', err)
% X -> vetor com parametros a serem encontrados; % R -> Residuos; 
% J -> jacobiana de modelfunction; CovB -> matriz de varianca e covarianca

[muJKR,R,J,CovB] = nlinfit(load, F, @JKR, eta0, 'Weights', err);
display(muJKR)

[muDMT, R2, J2, CovB2] = nlinfit(load, F, @DMT, eta0, 'Weights', err);
display(muDMT)


%% Fit com adesão como parâmetro livre

mu0 = [1 Fad];

[mu1, r1, j1, covb1] = nlinfit(load, F, @JKRAdh, mu0, 'Weights', err);
display(mu1)
AdhJKR = mu1(2);

[mu2, r2, j2, covb2] = nlinfit(load, F, @DMTAdh, mu0, 'Weights', err);
display(mu2)
AdhDMT = mu2(2);

%% Calculando o intervalo de confiança dos parâmetros estimados

RES_R = real(R); JAC_R = real(J); COV_R = real(CovB);

CI_R = nlparci(X_R, RES_R, 'covar', COV_R);

% Print parameters and Confidence Interval
% Display as par lb ub

par_R = [X_R' CI_R];
err_R = [par_R(1,1) - par_R(1,2), par_R(2,1) - par_R(2,2), par_R(3,1) - par_R(3,2)];
display(par_R);
display(err_R);

%% Plot data

figure(), errorbar(load, F, err, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
ylabel('Friction force (nN)','FontSize',16)
xlabel('Normal load (nN)','FontSize',16)
hold on

Lmin = min(load);
Lmax = max(load);

figstr = strcat(home, 'Applied-load-friction.png');
saveas(gcf, figstr, 'png');

%% Plot fittings

xfit1 = linspace(-Fad, max(load), 200);
yfit1 = JKR(muJKR, xfit1);
plot(xfit1, yfit1, 'r-', 'LineWidth', 2)

hold on
xfit2 = linspace(-Fad, max(load));
yfit2 = DMT(muDMT, xfit2);
h = plot(xfit2, yfit2, 'b-', 'LineWidth', 2);
legend('Data', 'JKR model', 'DMT model', 'Location', 'NorthWest')
hold off

figure(), errorbar(load, F, err, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8)
xlabel('Applied load (nN)', 'FontSize', 16)
ylabel('Friction force (nN)', 'FontSize', 16)
hold on

xadhJKR = linspace(-AdhJKR, max(load));
yadhJKR = JKRAdh(mu1, xadhJKR);

xadhDMT = linspace(-AdhDMT, max(load));
yadhDMT = DMTAdh(mu2, xadhDMT);

plot(xadhJKR, yadhJKR, 'r-', 'LineWidth', 2);
h3 = plot(xadhDMT, yadhDMT, 'b--', 'LineWidth', 2);
legend('Data', 'JKR model', 'DMT model', 'Location', 'NorthWest')
hold off

%% Salva os fittings e gráficos

figstr2 = strcat(home, 'Applied-Load-Friction-fits.png');
%saveas(h, figstr2, 'png');

outstr1 = strcat(home, 'JKR fit.txt');
outstr2 = strcat(home, 'DMT fit.txt');

varout1 = [xfit1' yfit1'];
varout2 = [xfit2' yfit2'];

dlmwrite(outstr1, varout1, '\t');
dlmwrite(outstr2, varout2, '\t');

figstr4 = strcat(home,'Applied-load-fits-adhesion-as-free-parameter.png');
%saveas(h3, figstr4, 'png');

varout4 = [xadhJKR' yadhJKR'];
varout5 = [xadhDMT' yadhDMT'];
outstr4 = strcat(home, 'JKR fit - adhesion as free parameter.txt');
outstr5 = strcat(home, 'DMT fit - adhesion as free parameter.txt');

dlmwrite(outstr4, varout4, '\t');
dlmwrite(outstr5, varout5, '\t');