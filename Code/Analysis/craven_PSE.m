%1. horizontal was used as standard(first row in data)
%2. find ratio first, then take the mean 
%3. find SEM

clear;
%
% Raw data: 1 by 64; ordered by the 2nd orientation;
% ([90,90],[60,90]...[90,60],[60,60]...[-45,-60],[-60,-60])

%================================ Load Data ===============================
load('./all_subject_parameters_with_fixed_lambda.mat');
all_subject_PSE = all_subject_parameters{1};
all_subject_PSE = all_subject_PSE(:, [1:size(all_subject_PSE,1) 1], :); %add 180
%==========================================================================


%================================ Variables ===============================
num_subjects = size(all_subject_PSE,3);
orientations = [0, 30, 45, 60, 90, 120, 135, 150, 180]; %IN INCREASING ORDER
num_orientations = length(orientations);
num_conditions = num_orientations^2;
standard_length = 3;
%==========================================================================

craven_orientations = [10 10:20:170];
craven = [1, 1.0108, 1.0693, 1.0969, 1.1041, 1.1003, 1.1103, 1.0911, 1.0654, 1.0173];
craven_normalized = craven;
craven_SEM = [0, 0.0033, 0.0095, 0.0141, 0.0158, 0.0138, 0.0138, 0.0135, 0.0097, 0.0053];

%============================Compute mean and SEM =========================
w = squeeze(all_subject_PSE(1,:,:));
mean_w = w./standard_length;
mean_w = mean(mean_w,2)';
sem_w = std(w,[],2)/standard_length/sqrt(num_subjects);
%==========================================================================


%==================================plotting================================
emmalinecol = [.75 .75 .75]; %grey
emmabasecol = [0 0 0]; %black
emmadiffcolor = [1 0 0]; %red

figure;
errorbar(craven_orientations, craven_normalized, craven_SEM, 'Color', 'm');
hold on;
errorbar(orientations, mean_w, sem_w, 'Color', emmabasecol, 'lineWidth', 2);


% plot settings
title('Data Comparison');
xlim([-10 190]);
% ylim([0.98  1.3]);
grid on;
xl = xlabel('Orientation ( ^\circ )');
yl = ylabel('Normalized perceived length');
h_legend = legend('Craven (1993)','Present study', 'Location','Best');

legend boxoff;
set(gca, 'XTick', 0:10:180);
set(gca, 'TickDir', 'out');
set(xl, 'FontSize', 12);
set(yl, 'FontSize', 12);
set(h_legend,'FontSize', 11);
%==========================================================================