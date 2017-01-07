
% Use Wilcoxon's signed rank test to determine whether 60 degree and 120
% degree are significantly different from 90degree
clear;

load('./all_subject_w_and_IBF.mat');
w = w_and_IBF{1};
num_subjects = size(w, 2);
orientations = [0, 30, 45, 60, 90, 120, 135, 150, 180];
num_orientations = length(orientations);
firstO = 60;
secondO = 120;
thirdO = 90;
fourthO = 45;
fifthO = 135;



%% Wilcoxon signed rank test

% compare 60 and 90
[p, h, stats] = signrank(w(orientations==firstO,:), w(orientations==thirdO,:),'method', 'approximate');
disp(['60&90: ', num2str(p), '. (reject=1, fail=0): ', num2str(h)]);
stats

% compare 120 and 90
[p, h, stats] = signrank(w(orientations==secondO,:), w(orientations==thirdO,:),'method', 'approximate');
disp(['120&90: ', num2str(p), '. (reject=1, fail=0): ', num2str(h)]);
stats

% compare 45 and 90
[p, h, stats] = signrank(w(orientations==fourthO,:), w(orientations==thirdO,:),'method', 'approximate');
disp(['45&90: ', num2str(p), '. (reject=1, fail=0): ', num2str(h)]);
stats

% compare 135 and 90
[p, h, stats] = signrank(w(orientations==fifthO,:), w(orientations==thirdO,:),'method', 'approximate');
disp(['135&90: ', num2str(p), '. (reject=1, fail=0): ', num2str(h)]);
stats