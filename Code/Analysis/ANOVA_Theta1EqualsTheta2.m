clear;

load('./Theta1EqualsTheta2.mat');


%============================== Variables =================================
num_subjects = 9;
orientations = [0, 30, 45, 60, 90, 120, 135, 150]; %IN INCREASING ORDER
num_orientations = length(orientations);
%==========================================================================



%================================== ANOVA =================================
condition_vector = repmat((1:num_orientations)',num_subjects, 1);

temp = repmat((1:num_subjects), num_orientations, 1);
subject_vector = temp(:);

p = anovan(equal_PSE_all(:), {condition_vector  subject_vector}, ...
    'random', 2, 'varnames',{'orientation', 'subject'});

%==========================================================================