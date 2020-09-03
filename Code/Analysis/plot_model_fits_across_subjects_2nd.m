clear;
% plot the average psychometric curve across all 9 subejcts
%   1) raw data as dots
%   2) Squared error of mean(std/sqrt(n)) as error bars
%   3) fitted psychometric (normcdf wth mu, sigma, lambda) as curves
%   4) difference in model fits as strips

%================================ Variables ===============================
referenceLength = 3;
num_comparison_length_steps = 100;
comparisonLength = linspace(2,4,num_comparison_length_steps);
orientations = [0 30 45 60 90 120 135 150];
num_orientations = length(orientations);
num_conditions = num_orientations^2;
num_subjects = 9;
num_repetitions_per_condition = 50;
num_bin_boundaries = 6;
num_bins = num_bin_boundaries - 1;
num_total_trials_per_subject = num_repetitions_per_condition * num_conditions;
%==========================================================================


%================================ Load Data ===============================
load('./all_subject_parameters_with_fixed_lambda.mat');
mu = all_subject_parameters{1}; %8by8by9
sigma = all_subject_parameters{2}; %8by8by9
lambda = all_subject_parameters{3}; %9by1

CM_data = load('./Experiment_code/Experiment_condition/(2nd)Subject_data/CM/CM_5_reordered.mat');
DS_data = load('./Experiment_code/Experiment_condition/(2nd)Subject_data/DS/DS_5_reordered.mat');
EL_data = load('./Experiment_code/Experiment_condition/(2nd)Subject_data/EL/EL_5_reordered.mat');
ET_data = load('./Experiment_code/Experiment_condition/(2nd)Subject_data/ET/ET_5_reordered.mat');
KG_data = load('./Experiment_code/Experiment_condition/(2nd)Subject_data/KG/KG_5_reordered.mat');
SD_data = load('./Experiment_code/Experiment_condition/(2nd)Subject_data/SD/SD_5_reordered.mat');
SS_data = load('./Experiment_code/Experiment_condition/(2nd)Subject_data/SS/SS_5_reordered.mat');
TT_data = load('./Experiment_code/Experiment_condition/(2nd)Subject_data/TT/TT_5_reordered.mat');
ZC_data = load('./Experiment_code/Experiment_condition/(2nd)Subject_data/ZC/ZC_5_reordered.mat');

all_data = [CM_data, DS_data, EL_data, ET_data, KG_data, SD_data, SS_data, TT_data, ZC_data];

all_trials = cell(num_orientations, num_orientations, num_subjects);
for sub_idx = 1:num_subjects
    for jj = 1:num_orientations
        for ii = 1:num_orientations
            all_trials{ii,jj, sub_idx} = all_data(sub_idx).post{ii,jj}.data(:, 1:2);
        end
    end
end
%==========================================================================

%================= Find bincenters(across all subjects) ===================
all_lengths = NaN(num_total_trials_per_subject*num_subjects, 1);
start_index = 1;
for sub_idx = 1:num_subjects
    for jj = 1:num_orientations
        for ii = 1:num_orientations
            all_lengths(start_index:start_index+num_repetitions_per_condition-1) = all_trials{ii,jj,sub_idx}(:, 1);
            start_index = start_index + num_repetitions_per_condition;
        end
    end
end

length_sorted = sort(all_lengths);
steps = linspace(0,length(all_lengths),num_bin_boundaries); %5 bins
steps(1) = 1;
bins = length_sorted(steps);

%==========================================================================


%====================== Plot curves with error bars =======================
% shared across plots
% map =[1,0,0; 0.9375,0.5,0.5; 0.5,0,0.5; 0.25,0.875,0.8125; 0,0,1];%[1 0 0; 0 0.8 0.8; 0.8 0.8 0; 0 0 1];%[1,0,0; 0.6,0,0; 0.8,0,0; 1,0,1; 0,0.8,1; 0,0.5,1; 0,0,1; 0,0,0]; % 1,0.75,0.75; 1,0.75,0.75; 1,0.5,0.5; 1,0.5,0.5; 1,0.25,0.25; 1,0.25,0.25; 0,0,1; 0,0,1];
% map = colors; %colors(ceil((1:2*size(colors,1))/2), :); %duplicate each color twice and place them right next to each other
% map = [0.8,0,0.2; 0.8,0.6,0.6; 0.6,0.4,0.6; 0.6,0.6,0.8; 0.2,0,0.8];
map = [0.9,0,0; 0.9,0.6,0.6; 0.6,0.4,0.6; 0.6,0.6,0.9; 0,0,0.9];
saturation_level = 0.9;
transparency_level = 0.3;

%% figure 1
orientations1 = [0 30 45 60 90];
plot_indices1 = [1 2 3 4 5];
num_plot_orientations1 = length(orientations1);
for jj = 1:num_orientations
    figure;
    axes('linewidth', 1.5);
    
    hold on;
    plot(repmat(3, 2, 1), [0,1], 'k--', 'linewidth', 2);
    hold on;
    
    plot([2 4], repmat(0.5, 2, 1), 'k--', 'linewidth', 2);
    hold on;
    
    for ii = 1:num_plot_orientations1
        
        bincenters = NaN(num_bins, 1);
        proplonger = NaN(num_bins, num_subjects);
        for sub_idx = 1:num_subjects
            this_data = all_trials{plot_indices1(ii), jj, sub_idx};
            
            for i = 1:num_bins
                bincenters(i) = mean(length_sorted(steps(i):steps(i+1)));
                idx = find(this_data(:,1) > (bins(i)-0.01) & this_data(:,1) <= bins(i+1));
                %                 if sum(idx) == 0
                %                     disp(['No trial for subject' num2str(sub_idx), ' and condition: ', num2str(plot_orientations(ii)), ' ', num2str(plot_orientations(jj))]);
                %                 end
                proplonger(i,sub_idx) = mean(this_data(idx,2)==1);
            end
        end
        
        % compute p for each subject
        p = NaN(num_subjects, num_comparison_length_steps);
        for sub_idx = 1:num_subjects
            p(sub_idx, :) = (1-lambda(sub_idx)) * normcdf(comparisonLength,...
                mu(plot_indices1(ii),jj,sub_idx), ...
                sigma(plot_indices1(ii),jj,sub_idx) + ...
                (0.5*lambda(sub_idx)));
        end
       
        
        % plot error bars
        color = rgb2hsv(map(ii, :));
        fillplot(comparisonLength, mean(p,1), std(p,[],1)/sqrt(num_subjects), map(ii,:), transparency_level, saturation_level);
        
        % plot fitted curve with normcdf
        hold on;
        h(ii) = plot(comparisonLength, mean(p,1), 'Color', map(ii,:), 'linewidth', 2);
       
        
    end
%     hold off;
    
    %     xl = xlabel('Comparison length (cm)');
    %     yl = ylabel('Proportion of responding "L1 is longer"');
    %     t = title(strcat('\theta2 =', ' ', sprintf('%d degree', orientations1(jj))));
    %     h_legend = legend(h, strcat('\theta_1 = ', num2str(orientations1'), '^\circ'), 'Location', 'SouthEast');
    
    
    %     set(xl, 'FontSize', 12);
    %     set(yl, 'FontSize', 12);
    %     set(t, 'FontSize', 11);
    %     set(h_legend,'FontSize', 11);
    %     legend boxoff;
    set(gca,'XTick',linspace(2,4,3));
    set(gca,'xticklabel',{[]});
    set(gca,'YTick',linspace(0,1,5));
    set(gca,'ticklength',3*get(gca,'ticklength'))
    set(gca,'yticklabel',{[]});
    set(gca, 'TickDir', 'out');
    
    set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [5 5]);
    saveas(gcf, ['model_fit_pos', num2str(jj)], 'pdf') %Save figure
end



%% figure 2
orientations2 = fliplr([90 120 135 150 180]);
plot_indices2 = fliplr([5 6 7 8 1]);
num_plot_orientations2 = length(orientations2);
for jj = 1:num_orientations
    figure;
    axes('linewidth', 1.5);
    
    hold on;
    plot(repmat(3, 2, 1), [0,1], 'k--', 'linewidth', 2);
    hold on;
    
    plot([2 4], repmat(0.5, 2, 1), 'k--', 'linewidth', 2);
    hold on;
    
    for ii = 1:num_plot_orientations2

        bincenters = NaN(num_bins, 1);
        proplonger = NaN(num_bins, num_subjects);
        for sub_idx = 1:num_subjects
            this_data = all_trials{plot_indices2(ii), jj, sub_idx};

            for i = 1:num_bins
                bincenters(i) = mean(length_sorted(steps(i):steps(i+1)));
                idx = find(this_data(:,1) > (bins(i)-0.01) & this_data(:,1) <= bins(i+1));
%                 if sum(idx) == 0
%                     disp(['No trial for subject' num2str(sub_idx), ' and condition: ', num2str(plot_orientations(ii)), ' ', num2str(plot_orientations(jj))]);
%                 end
                proplonger(i,sub_idx) = mean(this_data(idx,2)==1);
            end
        end

        % compute p for each subject
        p = NaN(num_subjects, num_comparison_length_steps);
        for sub_idx = 1:num_subjects
            p(sub_idx, :) = (1-lambda(sub_idx)) * normcdf(comparisonLength,...
                mu(plot_indices2(ii),jj,sub_idx), ...
                sigma(plot_indices2(ii),jj,sub_idx) + ...
                (0.5*lambda(sub_idx)));
        end


        % plot error bars
        hold on;
        fillplot(comparisonLength, mean(p,1), std(p,[],1)/sqrt(num_subjects), map(ii, :), transparency_level, saturation_level);

        % plot fitted curve with normcdf
        hold on;
        h(ii) = plot(comparisonLength, mean(p,1), 'Color', map(ii,:), 'linewidth', 2);
    end

%     axis([2 4 0 1]);
%     xl = xlabel('Comparison length (cm)');
%     yl = ylabel('Proportion of responding "L1 is longer"');
%     t = title(strcat('\theta2 = ', ' ', sprintf('%d degree', orientations2(jj))));
%     h_legend = legend(h, strcat('\theta_1 = ', num2str(orientations2'), '^\circ'), 'Location', 'SouthEast');

%     set(xl, 'FontSize', 12);
%     set(yl, 'FontSize', 12);
%     set(t, 'FontSize', 11);
%     set(h_legend,'FontSize', 11);
%     legend boxoff;

    set(gca,'XTick',linspace(2,4,3));
    set(gca,'xticklabel',{[]});
    set(gca,'YTick',linspace(0,1,5));
    set(gca,'ticklength',3*get(gca,'ticklength'));
    set(gca,'yticklabel',{[]});
    set(gca, 'TickDir', 'out');

    set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [5 5]);
    saveas(gcf, ['model_fit_neg', num2str(jj)], 'pdf') %Save figure
end
%==========================================================================