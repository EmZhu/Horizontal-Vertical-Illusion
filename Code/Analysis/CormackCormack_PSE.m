%1. horizontal was used as standard(first row in data)
%2. find mean first, then take ratio
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

cormack_orientations = [0, 22.5, 45, 67.5, 90, 112.5, 135, 155.5];
% cormack = [100, 109.6818, 112.0705, 114.8019, 113.4061, 114.7082,
% 113.8963, 109.4199]; %inverted T
cormack = [100, 105.1564, 108.1095, 108.8775, 103.6504, 108.4303, 107.1254, 104.9801]; % cross
cormack_normalized = cormack/cormack(1);
cormack_SEM = [0, 0.002, 0.0031, 0.0027, 0.0026, 0.0035, 0.0028, 0.0024] *sqrt(20);


%============================Compute mean and SEM =========================
w = squeeze(all_subject_PSE(1,:,:));
mean_w = mean(w,2)';
mean_w = mean_w./standard_length;
sem_w = std(w,[],2)/standard_length/sqrt(num_subjects);
%==========================================================================


%==================================plotting================================
emmalinecol = [.75 .75 .75]; %grey
emmabasecol = [0 0 0]; %black
emmadiffcolor = [1 0 0]; %red

figure;
errorbar(cormack_orientations, cormack_normalized, cormack_SEM, 'Color', 'b');
hold on;
errorbar(orientations, mean_w, sem_w, 'Color', emmabasecol, 'lineWidth', 2);


% plot settings
title('Data Comparison');
xlim([-10 190]);
% ylim([0.98  1.3]);
grid on;
xl = xlabel('Orientation ( ^\circ )');
yl = ylabel('Normalized perceived length');
h_legend = legend('Cormack & Cormack (1974)','Present study', 'Location','Best');

legend boxoff;
set(gca, 'XTick', 0:10:180);
set(gca, 'TickDir', 'out');
set(xl, 'FontSize', 12);
set(yl, 'FontSize', 12);
set(h_legend,'FontSize', 11);
%==========================================================================