clear;

load('./all_subject_parameters_with_fixed_lambda.mat');

all_subject_lambda = all_subject_parameters{3};

num_subjects = length(all_subject_lambda);

mean_lambda = mean(all_subject_lambda)
sem_lambda = std(all_subject_lambda)/sqrt(num_subjects)