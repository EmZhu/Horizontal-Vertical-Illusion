clear;

%================================ Variables ===============================
orientations = [0, 30, 45, 60, 90, 120, 135, 150, 180];
num_orientations = length(orientations);
standard_length = 3;

load('./all_subject_parameters_with_fixed_lambda.mat');
all_subject_PSE = all_subject_parameters{1};
% using only a subset of our data, i.e. when standard orientation is 0
all_subject_PSE_1st = all_subject_PSE([1:size(all_subject_PSE,1) 1], :, :);
all_subject_PSE_2nd = all_subject_PSE(:, [1:size(all_subject_PSE,1) 1], :);
num_subjects = size(all_subject_PSE, 3);
%==========================================================================



%==========================Data from other papers==========================
pollock_orientations = 0:10:180;
pollock_num_subjects = 40;

pollock_h_3 = [-0.02 -0.08 -0.16 -0.22 -0.25 -0.24 -0.31 -0.3 -0.29 -0.25...
    -0.3 -0.26 -0.24 -0.21 -0.15 -0.16 -0.1 -0.02 -0.02];
pollock_normalized_h_3 = (pollock_h_3./3)+1;
pollock_std_h_3 = [0.1 0.11 0.14 0.14 0.16 0.18 0.17 0.18 0.17 0.16 0.17...
    0.18 0.16 0.18 0.15 0.12 0.14 0.11 0.1];
pollock_SEM_h_3 = pollock_std_h_3./3./sqrt(pollock_num_subjects);

pollock_h_6 = [0.1 -0.06 -0.27 -0.42 -0.5 -0.59 -0.69 -0.5 -0.53 -0.52 ...
    -0.48 -0.54 -0.47 -0.44 -0.39 -0.28 -0.16 0.03 0.1];
pollock_normalized_h_6 = (pollock_h_6./6)+1;
pollock_std_h_6 = [0.23 0.22 0.28 0.3 0.23 0.32 0.33 0.36 0.36 0.33 0.36...
    0.33 0.36 0.3 0.3 0.29 0.27 0.37 0.23];
pollock_SEM_h_6 = pollock_std_h_6./6./sqrt(pollock_num_subjects);


pollock_v_3 = [0.27 0.28 0.2 0.14 0.1 0.05 -0.01 -0.03 -0.04 0.01 0.01 0.04...
    0.06 0.13 0.19 0.28 0.28 0.34 0.27];
pollock_normalized_v_3 = (pollock_v_3./3)+1;
pollock_std_v_3 = [0.2 0.18 0.19 0.18 0.12 0.12 0.11 0.12 0.12 0.11 0.1 ...
    0.09 0.12 0.15 0.14 0.19 0.21 0.19 0.2];
pollock_SEM_v_3 = pollock_std_v_3./3./sqrt(pollock_num_subjects);

pollock_v_6 = [0.58 0.49 0.51 0.27 0.1 -0.02 -0.04 -0.13 -0.09 -0.02 -0.03...
    -0.02 0.06 0.16 0.2 0.39 0.48 0.54 0.58];
pollock_normalized_v_6 = (pollock_v_6./6)+1;
pollock_std_v_6 = [0.47 0.44 0.36 0.31 0.29 0.25 0.22 0.21 0.2 0.16 0.18...
    0.23 0.24 0.3 0.32 0.37 0.4 0.43 0.47];
pollock_SEM_v_6 = pollock_std_v_6./6./sqrt(pollock_num_subjects);

pollock_data{1} = [pollock_normalized_h_3' pollock_SEM_h_3'];
pollock_data{2} = [pollock_normalized_h_6' pollock_SEM_h_6'];
pollock_data{3} = [pollock_normalized_v_3' pollock_SEM_v_3'];
pollock_data{4} = [pollock_normalized_v_6' pollock_SEM_v_6'];

save('./pollock_data','pollock_data');

craven_orientations = 10:20:170;
% craven = [1.0108, 1.0693, 1.0969, 1.1041, 1.1003, 1.1103, 1.0911, 1.0654, 1.0173];
craven = [1.016, 1.0801, 1.1118, 1.1208, 1.1152, 1.1251, 1.1059, 1.0767, 1.0252];
craven_normalized = 2 - craven;
craven_SEM = [0.0033, 0.0095, 0.0141, 0.0158, 0.0138, 0.0138, 0.0135, 0.0097, 0.0053];
% craven_SEM = [0.0062, 0.0178, 0.0264, 0.0296, 0.0258, 0.0258, 0.0253, ...
%     0.0181, 0.0099];

craven_data{1} = [craven_normalized' craven_SEM'];

save('./craven_data', 'craven_data');

cormack_orientations = 22.5:22.5:157.5;
cormack_other = 100;

cormack_cross = [5.1564, 8.1095, 8.8775, 3.6504, 8.4303, 7.1254, 4.9801]; % cross
cormack_normalized_cross = (cormack_cross./cormack_other)+1;
cormack_SEM_cross = [1.2649, 1.9606, 1.7076, 1.6444, 2.2136, 1.7709, 1.5179]./cormack_other;

cormack_t = [9.6818, 12.0705, 14.8019, 13.4061, 14.7082, 13.8963, 9.4199]; %inverted T
cormack_normalized_t = (cormack_t./cormack_other)+1;
cormack_SEM_t = [1.3874, 1.5554, 2.1878, 1.4877, 1.8177, 1.5013, 1.2057]./cormack_other;

cormack_data{1} = [cormack_normalized_cross' cormack_SEM_cross'];
cormack_data{2} = [cormack_normalized_t' cormack_SEM_t'];

save('./cormack_data','cormack_data');
%==========================================================================


%================================ Our data ================================
our_data_1st = squeeze(all_subject_PSE_1st(:,1,:)./standard_length);
our_data_2nd = squeeze(all_subject_PSE_1st(:,orientations==90,:)./standard_length);
our_data_3rd = squeeze(all_subject_PSE_2nd(1,:,:)./standard_length);
%==========================================================================

%===============Correction to account for Contraction Bias=================
%     load('./Theta1EqualsTheta2.mat');
%     correction_factor_per_subject = (mean(equal_PSE_all, 1)/standard_length)';
%     mean_bias_factor_across_subjects = mean(correction_factor_per_subject,1);
%     sem_bias_factor_across_subjects = std(correction_factor_per_subject,[],1)/sqrt(num_subjects);
%     bias_factor_across_subjects = [mean_bias_factor_across_subjects sem_bias_factor_across_subjects];
%     save('./bias_factor_across_subjects', 'bias_factor_across_subjects');
load('./all_subject_w_and_IBF.mat');
correction_factor_per_subject = w_and_IBF{2};
for ii = 1:num_subjects
    our_data_1st(:,ii) = our_data_1st(:,ii)./correction_factor_per_subject(ii);
    our_data_2nd(:,ii) = our_data_2nd(:,ii)./correction_factor_per_subject(ii);
    our_data_3rd(:,ii) = our_data_3rd(:,ii)./correction_factor_per_subject(ii);
end


%============================Compute mean and SEM =========================
mean_w_1st = mean(our_data_1st,2)';
sem_w_1st = (std(our_data_1st,[],2)/sqrt(num_subjects))';
mean_w_2nd = mean(our_data_2nd,2)';
sem_w_2nd = (std(our_data_2nd,[],2)/sqrt(num_subjects))';
mean_w_3rd = mean(our_data_3rd,2)';
sem_w_3rd = (std(our_data_3rd,[],2)/sqrt(num_subjects))';

standard_horizontal{1} = [mean_w_1st' sem_w_1st'];
standard_vertical{1} = [mean_w_2nd' sem_w_2nd'];
comparison_horizontal{1} = [mean_w_3rd' sem_w_3rd'];

save('./standard_horizontal','standard_horizontal');
save('./standard_vertical','standard_vertical');
save('./comparison_horizontal','comparison_horizontal');
%==========================================================================


%==================================plotting================================
ourscol      = [     0         0         0];    %black
col1         = [0.1059    0.6196    0.4667];    %greenish
col2         = [0.8510    0.3725    0.0078];    %orangeish
col3         = [0.4588    0.4392    0.7020];    %purpleish
% pollock_col3 = [0.6484    0.8047    0.8867];
% pollock_col4 = [0.6953    0.8711    0.5391];
% cormack_col1 = [0.7266    0.3320    0.8242];    %violetish
% cormack_col2 = [0.6445    0.1641    0.1641];    %brown


%% FIGURE 1: POLLOCK(2), CRAVEN, OURS
figure;
axes('linewidth', 1);
plot([orientations(1)-10 orientations(end)+10], ones(2, 1),'k--', 'lineWidth', 1.5);
hold on;
errorbar(pollock_orientations, pollock_normalized_h_3, pollock_SEM_h_3, 'Color', col1, 'lineWidth', 2);
hold on;
errorbar(pollock_orientations, pollock_normalized_h_6, pollock_SEM_h_6, 'Color', col2, 'lineWidth', 2);
hold on;
errorbar(craven_orientations, craven_normalized, craven_SEM, 'Color', col3, 'lineWidth', 2);
hold on;
errorbar(orientations, mean_w_1st, sem_w_1st, 'Color', ourscol, 'lineWidth', 2);


% plot settings
% title('Data Comparison');
xlim([-10 190]);
grid on;
ax = gca;
ax.GridAlpha = 0.3;
ylim([0.8  1.2]);
% xl = xlabel('Orientation ( ^\circ )');
% yl = ylabel('Bias factor (orientation) / bias factor (horizontal)');
% h_legend = legend('Pollock & Chapanis (1952) horizontal 3 inch','Pollock & Chapanis (1952) horizontal 6 inch', 'Craven (1993)', 'Present study', 'Location','Best');

% legend boxoff;
set(gca, 'XTick', 0:30:180);
set(gca,'xticklabel',{[]});
set(gca,'yticklabel',{[]});
set(gca, 'TickDir', 'out');
% set(xl, 'FontSize', 12);
% set(yl, 'FontSize', 12);
% set(h_legend,'FontSize', 11);
set(gca,'ticklength',2*get(gca,'ticklength'));

num = 5;
set(gcf, 'PaperPosition', [0 0 num num]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [num num]);
saveas(gcf, 'data_comparison_old_paper_1', 'pdf') %Save figure


%% FIGURE 2: Pollock(2), OURS
figure;
axes('linewidth', 1);
plot([orientations(1)-10 orientations(end)+10], ones(2, 1),'k--', 'lineWidth', 1.5);
hold on;
errorbar(pollock_orientations, pollock_normalized_v_3, pollock_SEM_v_3, 'Color', col1, 'lineWidth', 2);
hold on;
errorbar(pollock_orientations, pollock_normalized_v_6, pollock_SEM_v_6, 'Color', col2, 'lineWidth', 2);
hold on;
errorbar(orientations, mean_w_2nd, sem_w_2nd, 'Color', ourscol, 'lineWidth', 2);


% plot settings
% title('Data Comparison');
xlim([-10 190]);
grid on;
ax = gca;
ax.GridAlpha = 0.3;
ylim([0.8  1.2]);
% xl = xlabel('Orientation ( ^\circ )');
% yl = ylabel('Bias factor (orientation) / bias factor (horizontal)');
% h_legend = legend('Pollock & Chapanis (1952) vertical 3 inch','Pollock & Chapanis (1952) vertical 6 inch', 'Present study', 'Location','Best');

% legend boxoff;
set(gca, 'XTick', 0:30:180);
set(gca,'xticklabel',{[]});
set(gca,'yticklabel',{[]});
set(gca, 'TickDir', 'out');
% set(xl, 'FontSize', 12);
% set(yl, 'FontSize', 12);
% set(h_legend,'FontSize', 11);
set(gca,'ticklength',2*get(gca,'ticklength'));

num = 5;
set(gcf, 'PaperPosition', [0 0 num num]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [num num]);
saveas(gcf, 'data_comparison_old_paper_2', 'pdf') %Save figure
    


%% FIGURE 3: CORMACK(2), OURS
figure;
axes('linewidth', 1);
plot([orientations(1)-10 orientations(end)+10], ones(2, 1),'k--', 'lineWidth', 1.5);
hold on;
errorbar(cormack_orientations, cormack_normalized_cross, cormack_SEM_cross, 'Color', col1, 'lineWidth', 2);
hold on;
errorbar(cormack_orientations, cormack_normalized_t, cormack_SEM_t, 'Color', col2, 'lineWidth', 2);
hold on;
errorbar(orientations, mean_w_3rd, sem_w_3rd, 'Color', ourscol, 'lineWidth', 2);

% plot settings
% title('Data Comparison');
xlim([-10 190]);
ylim([0.8  1.2]);
grid on;
ax = gca;
ax.GridAlpha = 0.3;
% xl = xlabel('Orientation ( ^\circ )');
% yl = ylabel('Bias factor (horizontal) / bias factor (orientation)');
% h_legend = legend('Cormack & Cormack (1974) +', 'Cormack & Cormack (1974) T', 'Present study', 'Location','Best');

% legend boxoff;
set(gca, 'XTick', 0:30:180);
set(gca,'xticklabel',{[]});
set(gca,'yticklabel',{[]});
set(gca, 'TickDir', 'out');
% set(gca,'fontsize', 12);
set(gca,'ticklength',2*get(gca,'ticklength'));
% set(xl, 'FontSize', 12);
% set(yl, 'FontSize', 12);
% set(h_legend,'FontSize', 22);


set(gcf, 'PaperPosition', [0 0 num num]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [num num]);
saveas(gcf, 'data_comparison_old_paper_3', 'pdf') %Save figure

%==========================================================================