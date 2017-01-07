clear;

%================================ Load Data ===============================
load('./all_subject_parameters_with_fixed_lambda.mat');
all_subject_PSE = all_subject_parameters{1};
%==========================================================================


%============================== Variables =================================
num_subjects = 9;
orientations = [0, 30, 45, 60, 90, 120, 135, 150]; %IN INCREASING ORDER
num_orientations = length(orientations);
num_conditions = num_orientations^2;
corrected_orientations = [0, 30, 45, 60, 90];
num_corrected_orientations = length(corrected_orientations);
num_corrected_conditions = num_corrected_orientations^2;
%==========================================================================


%==============Combine positive and negative orientations==================
temp = NaN(num_corrected_orientations, num_orientations, num_subjects);

temp([1 5],:,:) = all_subject_PSE([1 5],:,:);
temp(2,:,:) = mean(all_subject_PSE([2,8],:,:),1);
temp(3,:,:) = mean(all_subject_PSE([3,7],:,:),1);
temp(4,:,:) = mean(all_subject_PSE([4,6],:,:),1);

all_subject_PSE_combined(:,[1 5],:) = temp(:,[1 5],:);
all_subject_PSE_combined(:,2,:) = mean(temp(:,[2,8],:),2);
all_subject_PSE_combined(:,3,:) = mean(temp(:,[3,7],:),2);
all_subject_PSE_combined(:,4,:) = mean(temp(:,[4,6],:),2);
%==========================================================================



%================================== ANOVA =================================
condition_matrix = repmat(CombVec(linspace(1,num_corrected_orientations, ...
    num_corrected_orientations),linspace(1,num_corrected_orientations, ...
    num_corrected_orientations))', num_subjects, 1);

temp = repmat(1:num_subjects, num_corrected_conditions, 1);
subject_vector = temp(:);

p = anovan(all_subject_PSE_combined(:), {condition_matrix(:,1) condition_matrix(:,2) subject_vector}, ...
    'random', 3, 'model', 'interaction', 'varnames',{'1st orien', '2nd orien', 'subject'});

%==========================================================================

