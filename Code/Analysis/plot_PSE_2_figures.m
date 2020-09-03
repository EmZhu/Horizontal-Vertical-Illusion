% PLOT PSE IN 2 FIGURES (PSE as a function of the orientation of comparison
% line)

clear;
% raw data: 
% top left entry of matrix: 0&0
% bottom left: 150&0
% top right: 0&150
% bottom right: 150&150

%================================ Load Data ===============================
load('./all_subject_parameters_with_fixed_lambda.mat');
all_subject_PSE = all_subject_parameters{1};
all_subject_PSE = all_subject_PSE([1:size(all_subject_PSE,2) 1], :, :); %add 180
%==========================================================================


%================================ Variables ===============================
num_subjects = size(all_subject_PSE,3);
orientations = [0, 30, 45, 60, 90, 120, 135, 150, 180]; %IN INCREASING ORDER
num_orientations = length(orientations);
num_conditions = num_orientations^2;
%==========================================================================

%================================ Plotting ================================

%% FIGURE 1: PLOT 0,30,45,60,90
figure;
axes('linewidth', 1);
% map =  [.39 .04 .05; .80 .31 .34; .76 .76 .76; .48 .73 .79; .10 .28 .42]; %[1,0,0; 1,0.5,0.5; 0.5,0,0.5; 0.5,0.5,1; 0,0,1];
% map = [1 0 0; .575 .40 .405; .76 .76 .76; .48 .73 .79; 0 0 1];
map = [0.9,0,0; 0.9,0.6,0.6; 0.6,0.4,0.6; 0.6,0.6,0.9; 0,0,0.9];

set(gca, 'ColorOrder', map, 'NextPlot', 'replacechildren');

orientations1 = [0, 30, 45, 60, 90];
selected_PSE1 = all_subject_PSE(:, 1:5, :);
all_mean_PSE1 = mean(selected_PSE1, 3);
all_SEM1 = std(selected_PSE1,[],3)/sqrt(num_subjects);
errorbar(repmat(orientations,length(orientations1),1)', all_mean_PSE1, all_SEM1,'linewidth',2); % each column is a line
hold on;
plot([orientations(1) orientations(end)], repmat(3, 2, 1), 'k--','linewidth',2);

% grid on;
% ax = gca;
% ax.GridAlpha = 0.3;
xlim([orientations(1)-10, orientations(end)+10]);
ylim([2.5, 3.5]);
% xl = xlabel('\theta_{s} ( ^\circ )');
% yl = ylabel('PSE (cm)');
% t = title('PSE for Positive Conditions');
% h_legend = legend(strcat('\theta_{c} = ', {' '}, num2str(orientations1'),'^\circ'),'Location','Best');

% [legh,objh,outh,outm] = legend(repmat(' ',length(orientations1)),'Location','Best');
% hL=findobj(objh,'type','line');
% set(hL,'linewidth',2);

set(gca, 'box','off','xgrid','off','ygrid','off');
set(gca, 'XTick', orientations);
% set(gca, 'yTick', 2.5:0.15:3.5);
set(gca,'xticklabel',{[]});
set(gca,'yticklabel',{[]});
% set(gca, 'box','off');
set(gca,'ticklength',2*get(gca,'ticklength'));
% set(xl, 'FontSize', 16);
% set(yl, 'FontSize', 16);
% set(h_legend,'FontSize', 15);
% set(t, 'FontSize', 11);
% legend boxoff;
set(gca, 'TickDir', 'out');

set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 5]);
saveas(gcf, 'PSE_pos', 'pdf'); %Save figure


%%
% FIGURE 2: PLOT 90, 120, 135, 150, 180
figure;
axes('linewidth', 1);
map = [0.9,0,0; 0.9,0.6,0.6; 0.6,0.4,0.6; 0.6,0.6,0.9; 0,0,0.9];
% map = [1 0 0; .80 0 .34; .5 0 .5; .23 0 .80; 0 0 1];
set(gca, 'ColorOrder', map, 'NextPlot', 'replacechildren');

orientations2 = [90, 120, 135, 150, 180];
selected_PSE2 = all_subject_PSE(:, [1 8:-1:5], :);
all_mean_PSE2 = mean(selected_PSE2, 3);
all_SEM2 = std(selected_PSE2,[],3)/sqrt(num_subjects);

errorbar(repmat(orientations,length(orientations2),1)', all_mean_PSE2, all_SEM2, 'LineWidth', 2);
hold on;
plot([orientations(1) orientations(end)], repmat(3, 2, 1), 'k--', 'linewidth',2);
% 
% grid on;
% ax = gca;
% ax.GridAlpha = 0.3;
xlim([orientations(1)-10, orientations(end)+10]);
ylim([2.5, 3.5]);
% xl = xlabel('\theta_{s} ( ^\circ )');
% yl = ylabel('PSE (cm)');
% h_legend = legend(repmat(' ',length(orientations2)),'Location','Best');

set(gca, 'box','off','xgrid','off','ygrid','off');
% t = title('PSE for Negative Conditions');
% h_legend = legend(strcat('\theta_{c} = ',{' '}, num2str(fliplr(orientations2)'),'^\circ'),'Location','Best');
set(gca, 'XTick', orientations);
% set(gca, 'yTick', 2.5:0.:3.5);
set(gca,'xticklabel',{[]});
set(gca,'yticklabel',{[]});
% set(gca, 'box','off');
% set(xl, 'FontSize', 12);
% set(yl, 'FontSize', 12);
% set(h_legend,'FontSize', 11);
% set(t, 'FontSize', 11);
set(gca,'ticklength',2*get(gca,'ticklength'));
% legend boxoff;
set(gca, 'TickDir', 'out');

set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 5]);
saveas(gcf, 'PSE_neg', 'pdf'); %Save figure
%==========================================================================