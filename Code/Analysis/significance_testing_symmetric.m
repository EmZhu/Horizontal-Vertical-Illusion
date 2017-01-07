
% Use Wilcoxon's signed rank test to determine whether the HVI is symmetric
% (i.e. to test if illusory effect at 30deg is same as that at 150deg; same for 45deg & 135deg,
% 60deg & 120deg)
clear;

load('./all_subject_parameters_with_fixed_lambda.mat');
all_subject_PSE = all_subject_parameters{1};
num_subjects = size(all_subject_PSE, 3);
orientations = [0, 30, 45, 60, 90, 120, 135, 150];
num_orientations = length(orientations);


%% fitting u using fmincon
% ratio at 0 degree is forced to be 1(as normalization constant) when
% fitting u

w = NaN(num_orientations, num_subjects);
options = optimset('Display', 'off'); %suppressing fmincon messages

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
        
        find 'u' that gives the least loss from 'f'
        u = min_u;
        IBF(ii) = u(8);
        
        insert back 1 for 0 degree
        u_new = [1 u(1:7) 1];
        
        w(:,ii) = 1./u_new; 
    
    end
    w_and_IBF{1} = w;
    w_and_IBF{2} = IBF;
    
    save('./all_subject_w_and_IBF', 'w_and_IBF');
end

%% Wilcoxon signed rank test

% compare 30 and 150
[p, h, stats] = signrank(w(2,:), w(8,:),'method', 'approximate');
disp(['30&150: ', num2str(p)]);
stats

% compare 45 and 135
[p, h, stats] = signrank(w(3,:), w(7,:),'method', 'approximate');
disp(['45&135: ', num2str(p)]);
stats

% compare 60 and 120
[p, h, stats] = signrank(w(4,:), w(6,:),'method', 'approximate');
disp(['60&120: ', num2str(p)]);
stats


