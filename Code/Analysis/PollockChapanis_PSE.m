%1. horizontal was used as reference (first column in data)
%2. find mean first, then take ratio
%3. find SEM
% 
clear;
%
% Raw data: 1 by 64; ordered by the 2nd orientation;
% ([90,90],[60,90]...[90,60],[60,60]...[-45,-60],[-60,-60])

%================================ Load Data ===============================
load('./all_subject_parameters_with_fixed_lambda.mat');
all_subject_PSE = all_subject_parameters{1};
all_subject_PSE = all_subject_PSE([1:size(all_subject_PSE,1) 1], :, :); %add 180
%==========================================================================


%================================ Variables ===============================
num_subjects = size(all_subject_PSE,3);
orientations = [0, 30, 45, 60, 90, 120, 135, 150, 180]; %IN INCREASING ORDER
num_orientations = length(orientations);
num_conditions = num_orientations^2;
standard_length = 3;
%==========================================================================

pollock_orientations = 0:10:180;
pollock = [-0.0232, -0.0808, -0.1630, -0.2191, -0.2531, -0.2421, -0.3076,...
    -0.3022, -0.2896, -0.2471, -0.2976, -0.2582, -0.2402, -0.2063, -0.1472...
    -0.1606, -0.0984, -0.0195, -0.0232];
pollock = pollock + 3;
pollock_normalized = pollock./3;
pollock_SEM = [0.0078, 0.0086, 0.0105, 0.0118, 0.0135, 0.0129, 0.0135,...
    0.0125, 0.0123, 0.0129, 0.0135, 0.0119, 0.0135, 0.011, 0.0093, 0.0105,...
    0.0086, 0.0077, 0.0078];

%============================Compute mean and SEM =========================
w = squeeze(all_subject_PSE(:,1,:));
mean_w = mean(w,2)';
mean_w = mean_w./standard_length;
sem_w = std(w,[],2)/standard_length/sqrt(num_subjects);
%==========================================================================


%==================================plotting================================
emmalinecol = [.75 .75 .75]; %grey
emmabasecol = [0 0 0]; %black
emmadiffcolor = [1 0 0]; %red

figure;
errorbar(pollock_orientations, pollock_normalized, pollock_SEM, 'Color', emmadiffcolor);
hold on;
errorbar(orientations, mean_w, sem_w, 'Color', emmabasecol, 'lineWidth', 2);


% plot settings
title('Data Comparison');
xlim([-10 190]);
% ylim([0.98  1.3]);
grid on;
xl = xlabel('Orientation ( ^\circ )');
yl = ylabel('Normalized perceived length');
h_legend = legend('Pollock & Chapanis (1952)','Present study', 'Location','Best');

legend boxoff;
set(gca, 'XTick', 0:10:180);
set(gca, 'TickDir', 'out');
set(xl, 'FontSize', 12);
set(yl, 'FontSize', 12);
set(h_legend,'FontSize', 11);
%==========================================================================