% R^2 test
function significance_testing_older_papers()

clear;

load('./pollock_data.mat');
load('./craven_data.mat');
load('./cormack_data.mat');
load('./standard_horizontal.mat');
load('./standard_vertical.mat');
load('./comparison_horizontal.mat');


%================================ Variables ===============================
orientations = [0, 30, 45, 60, 90, 120, 135, 150, 180];
% num_orientations = length(orientations);
% standard_length = 3;
interpolation_method = 'pchip';
%==========================================================================

our_h_standard = standard_horizontal{1}(:,1);
our_v = standard_vertical{1}(:,1);
our_h_comparison = comparison_horizontal{1}(:,1);


%% pollock (new orientation range after correction: 0:10:170 + 45 + 135)
pollock_orientations = 0:10:170;
p_orientations = union(pollock_orientations, orientations);
% p_orientations_corrected = p_orientations(1:end-1);
p_our_h = interp1(orientations, our_h_standard(1:end)', p_orientations, interpolation_method);
p_our_v = interp1(orientations, our_v(1:end)', p_orientations, interpolation_method);

p_our_h_corrected = p_our_h(1:end-1);
p_our_v_corrected = p_our_v(1:end-1);


% horizontal standard, 3-inch
p_h_3 = pollock_data{1}(:,1);
complete_p_h_3 = interp1(pollock_orientations, p_h_3(1:end-1)', p_orientations, interpolation_method);
complete_p_h_3_corrected = complete_p_h_3(1:end-1);

r_p_h_3 = r2(p_our_h_corrected, complete_p_h_3_corrected)

% horizontal standard, 6-inch
p_h_6 = pollock_data{2}(:,1);
complete_p_h_6 = interp1(pollock_orientations, p_h_6(1:end-1)', p_orientations, interpolation_method);
complete_p_h_6_corrected = complete_p_h_6(1:end-1);

r_p_h_6 = r2(p_our_h_corrected, complete_p_h_6_corrected)

% vertical standard, 3-inch
p_v_3 = pollock_data{3}(:,1);
complete_p_v_3 = interp1(pollock_orientations, p_v_3(1:end-1)', p_orientations, interpolation_method);
complete_p_v_3_corrected = complete_p_v_3(1:end-1);

r_p_v_3 = r2(p_our_v_corrected, complete_p_v_3_corrected)


% vertical standard, 6-inch
p_v_6 = pollock_data{4}(:,1);
complete_p_v_6 = interp1(pollock_orientations, p_v_6(1:end-1)', p_orientations, interpolation_method);
complete_p_v_6_corrected = complete_p_v_6(1:end-1);

r_p_v_6 = r2(p_our_v_corrected, complete_p_v_6_corrected)


%% craven (new orientation range after correction: 10:20:170 + 45 + 60 + 135 + 120)
craven_orientations = 10:20:170;
cr_orientations = union(craven_orientations, orientations);
% cr_orientations_corrected = cr_orientations(2:end-1);
cr_our = interp1(orientations, our_h_standard', cr_orientations, interpolation_method);
cr_our_corrected = cr_our(2:end-1);

cr = craven_data{1}(:,1);
complete_cr = interp1(craven_orientations, cr', cr_orientations, interpolation_method);
complete_cr_corrected = complete_cr(2:end-1);

r_cr = r2(cr_our_corrected, complete_cr_corrected)

%% cormack (new orientation range after correction: 10:20:170 + 45 + 60 + 135 + 120)
cormack_orientations = 22.5:22.5:157.5;
co_orientations = union(cormack_orientations, orientations);
% co_orientations_corrected = co_orientations(2:end-1);

co_our = interp1(orientations, our_h_comparison', co_orientations, interpolation_method);
co_our_corrected = co_our(2:end-1);

% cross
co_cross = cormack_data{1}(:,1);
complete_co_cross = interp1(cormack_orientations, co_cross', co_orientations, interpolation_method);
complete_co_cross_corrected = complete_co_cross(2:end-1);
co_our_corrected
complete_co_cross_corrected
r_co_cross = r2(co_our_corrected, complete_co_cross_corrected)

figure
scatter(co_our_corrected, complete_co_cross_corrected)
hold on
hline = plot([1,1.15], [1,1.15]);
set(hline, 'LineStyle', '- -', 'Color', 'k')
title('PSE of Cross-like Study in Cormack&Cormack vs. PSE of This Study')
xlabel('PSE of this study (cm)')
ylabel('PSE of Cross-like study (cm)')
% set(gca, 'XTick', orientations);

% inverted T
co_t = cormack_data{2}(:,1);
complete_co_t = interp1(cormack_orientations, co_t', co_orientations, interpolation_method);
complete_co_t_corrected = complete_co_t(2:end-1);

r_co_t = r2(co_our_corrected, complete_co_t_corrected)


end

%% Function
% FORMULA: r^2 = 1  -  (var(mean_study1-mean_study2) / (var(mean_study1)+var(mean_study2))/2))

function val = r2(study1, study2)
% disp(study1)
% disp(study2)
% disp('numerator')
% disp(var(study1 - study2))
% disp('denominator(1)')
% disp(var(study1))
% disp(var(study2))
val = 1 - (var(study1-study2) / ((var(study1)+var(study2))/2));
end


