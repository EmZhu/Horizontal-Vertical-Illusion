clear;

%================================ Variables ===============================
load('./all_subject_parameters_with_fixed_lambda.mat');
all_subject_PSE = all_subject_parameters{1};
average_PSE = mean(all_subject_PSE, 3);
num_subjects = size(all_subject_PSE, 3);
orientations = [0, 30, 45, 60, 90, 120, 135, 150, 180];
num_orientations = length(orientations);
standard_length = 3;
%==========================================================================



%==========================fitting u using fmincon=========================
% ratio at 0 degree is forced to be 1(as normalization constant) when
% fitting u

filename = 'all_subject_w_and_IBF.mat';
if exist(filename, 'file') == 2 
    load(filename);
    w = w_and_IBF{1};
    IBF = w_and_IBF{2};
else
    w = NaN(num_orientations, num_subjects);
    options = optimset('Display', 'off'); %suppressing fmincon messages
    for ii = 1:num_subjects
        f = @(u) sum(sum((all_subject_PSE(:,:,ii)-3*u(8) * [1 u(1:7)]'*(1./[1 u(1:7)])).^2));
        min_u = NaN;
        min_loss = NaN;
        
        for jj = 1:100
            u = fmincon(f,randn(1,8)*0.3+1,[],[],[],[],0.5*ones(1,8),2*ones(1,8), [], options);
            temp_loss = f(u);
            if (isnan(min_loss) == 1) || (temp_loss < min_loss)
                min_u = u;
                min_loss = temp_loss;
            end
        end
        
        % find 'u' that gives the least loss from 'f'
        u = min_u;
        IBF(ii) = u(8);
        
        % insert back 1 for 0 degree
        u_new = [1 u(1:7) 1];
        
        w(:,ii) = 1./u_new; 
    
    end
    w_and_IBF{1} = w;
    w_and_IBF{2} = IBF;
    
    save('./all_subject_w_and_IBF', 'w_and_IBF');
end

%==========================================================================

all_subject_PSE = NaN(num_orientations, num_orientations, num_subjects);

for sub_idx = 1:num_subjects
    all_subject_PSE(:,:,sub_idx) = (1./w(:,sub_idx)) * w(:,sub_idx)' * IBF(sub_idx) * standard_length;
end


%% figure;
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

grid on;
ax = gca;
ax.GridAlpha = 0.3;
xlim([orientations(1)-10, orientations(end)+10]);
ylim([2.5, 3.5]);
% xl = xlabel('\theta_{s} ( ^\circ )');
% yl = ylabel('PSE (cm)');
% t = title('PSE for Positive Conditions');
% h_legend = legend(strcat('\theta_{c} = ', {' '}, num2str(orientations1'),'^\circ'),'Location','Best');

% [legh,objh,outh,outm] = legend(repmat(' ',length(orientations1)),'Location','Best');
% hL=findobj(objh,'type','line');
% set(hL,'linewidth',2);

set(gca, 'XTick', orientations);
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
saveas(gcf, 'PSE_model_pos', 'pdf'); %Save figure

%% figure;
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

grid on;
ax = gca;
ax.GridAlpha = 0.3;
xlim([orientations(1)-10, orientations(end)+10]);
ylim([2.5, 3.5]);
% xl = xlabel('\theta_{s} ( ^\circ )');
% yl = ylabel('PSE (cm)');
% h_legend = legend(repmat(' ',length(orientations2)),'Location','Best');

% t = title('PSE for Negative Conditions');
% h_legend = legend(strcat('\theta_{c} = ',{' '}, num2str(fliplr(orientations2)'),'^\circ'),'Location','Best');
set(gca, 'XTick', orientations);
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
saveas(gcf, 'PSE_model_neg', 'pdf'); %Save figure