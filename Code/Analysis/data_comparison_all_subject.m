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



%============================Compute mean and SEM =========================
mean_w = mean(w,2)';
sem_w = (std(w,[],2)/sqrt(num_subjects))';

% confidence interval
wv = w(5,:);
nsamples = 10000;
newmean = NaN(1,nsamples);
for i=1:nsamples
    newmean(i) = mean(randsample(wv,num_subjects,true));
end
ci = 100*(quantile(newmean, [0.025 0.5 0.975])-1);

%==========================================================================


%==================================plotting================================

emmalinecol = [.75 .75 .75]; %grey
emmabasecol = [0 0 0]; %black
emmadiffcolor = [1 0 0]; %red

figure;
colors = distinguishable_colors(num_subjects);
for ii = 1:num_subjects
    hold on;
    plot(orientations, w(:,ii), 'Color', colors(ii, :));
end
hold on;
errorbar(orientations, mean_w, sem_w, 'Color', emmabasecol, 'lineWidth', 2);

% plot settings
% title('Data Comparison');
xlim([-10 190]);
ylim([0.98  1.3]);
grid on;
ax = gca;
ax.GridAlpha = 0.3;
box on;
% xl = xlabel('Orientation ( ^\circ )');
% yl = ylabel('Normalized perceived length');
% h_legend = legend('Subject 1','Subject 2','Subject 3','Subject 4',...
%     'Subject 5','Subject 6','Subject 7','Subject 8','Subject 9','Average', 'Location','Best');

% legend boxoff;
set(gca, 'XTick', orientations);
set(gca, 'TickDir', 'out');
set(gca,'xticklabel',{[]});
set(gca,'yticklabel',{[]});
% set(xl, 'FontSize', 12);
% set(yl, 'FontSize', 12);
% set(h_legend,'FontSize', 11);
set(gca,'ticklength',2*get(gca,'ticklength'));

set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 5]);
saveas(gcf, 'data_comparison_all_subjects', 'pdf'); %Save figure
